import Foundation
import Socket

extension RPC {
    func createSocket() throws {
        do {
            self.socket = try Socket.create(family: .unix, proto: .unix)
            try self.socket?.setBlocking(mode: true)
        } catch {
            throw RPCError.socketCreation(error: error)
        }
    }

    func closeSocket() {
        self.socket?.close()
        self.socket = nil
    }

    func handshake() throws {
        let request = try RequestHandshake(clientID: self.clientId)
        let requestJSON = try request.jsonString()
        logger.info("[RPC] Kicking off handshake with JSON: \(requestJSON)")

        try self.send(requestJSON, .handshake)
        self.receive()
    }

    public func connect() throws {
        if ProcessInfo.processInfo.environment["APP_SANDBOX_CONTAINER_ID"] != nil {
            throw RPCError.appSandboxed
        }
        try self.createSocket()
        logger.info("[RPC] Created socket.")

        let path = NSTemporaryDirectory()
        for suffix in udsSuffixRange {
            try? self.socket!.connect(to: "\(path)discord-ipc-\(suffix)")

            guard !self.socket!.isConnected else {
                do {
                    logger.info("[RPC] Connected to socket at \(path)discord-ipc-\(suffix)")
                    try self.handshake()
                    return
                } catch {
                    self.closeSocket()
                    throw error
                }
            }
        }

        throw RPCError.udsNotFound(path: path)
    }
    
    func send(_ msg: String, _ opCode: OPCode) throws {
        let payload = msg.data(using: .utf8)!
        var buffer = UnsafeMutableRawBufferPointer.allocate(
                byteCount: 8 + payload.count,
                alignment: MemoryLayout<UInt8>.alignment
        )
        defer { buffer.deallocate() }

        buffer.copyBytes(from: payload)
        buffer[8...] = buffer[..<payload.count]
        buffer.storeBytes(of: opCode.rawValue, as: UInt32.self)
        buffer.storeBytes(of: UInt32(payload.count), toByteOffset: 4, as: UInt32.self)

        try self.socket?.write(from: buffer.baseAddress!, bufSize: buffer.count)
    }
    
    func syncResponse(requestJSON: String, nonce: String, disableTimeout: Bool = false) throws -> Data {
        let semaphore = DispatchSemaphore(value: 0)
        var notification: Notification?
        var response: Data
        var error: EventErrorData?

        var observer: NSObjectProtocol?
        observer = self.cmdNotifCenter.addObserver(
            forName: NSNotification.Name(nonce),
            object: nil,
            queue: nil
        ) { notif in
            notification = notif
            semaphore.signal()
        }

        try self.send(requestJSON, .frame)

        if disableTimeout {
            semaphore.wait()
        } else {
            if semaphore.wait(timeout: .now() + .milliseconds(self.cmdTimeout)) == .timedOut {
                self.cmdNotifCenter.removeObserver(observer!)
                throw CommandError.timeout(timeout: self.cmdTimeout)
            }
        }
        self.cmdNotifCenter.removeObserver(observer!)

        do {
            let dict = notification!.userInfo! as NSDictionary
            // swiftlint:disable force_cast
            response = dict["data"] as! Data
            if dict["error"] as! Bool {
            // swiftlint:enable force_cast
                let event = try EventError.from(data: response)
                error = event.data
            }
        } catch {
            throw CommandError.responseMalformed(response: notification)
        }

        if let error = error { throw CommandError.failed(code: error.code, message: error.message) }

        return response
    }
    
    func receive() {
        self.rpcWorker.async { [unowned self] in
            while true {
                guard let isConnected = self.socket?.isConnected, isConnected else {
                    self.disconnectHandler?(self, EventClose(code: .socketDisconnected, message: "Socket Disconnected"))
                    return
                }

                do {
                    let headerPtr = UnsafeMutablePointer<Int8>.allocate(capacity: 8)
                    let headerRawPtr = UnsafeRawPointer(headerPtr)
                    defer { free(headerPtr) }

                    var response = try self.socket?.read(into: headerPtr, bufSize: 8, truncate: true)
                    guard response! > 0 else {
                        logger.warning("[RPC] Receive: header length is 0")
                        continue
                    }

                    let opValue = headerRawPtr.load(as: UInt32.self)
                    let length = headerRawPtr.load(fromByteOffset: 4, as: UInt32.self)
                    guard length > 0, let op = OPCode(rawValue: opValue) else {
                        logger.warning("[RPC] Receive: opcode length is 0")
                        continue
                    }

                    let payloadPtr = UnsafeMutablePointer<Int8>.allocate(capacity: Int(length))
                    defer { free(payloadPtr) }

                    response = try self.socket?.read(into: payloadPtr, bufSize: Int(length), truncate: true)
                    guard response! > 0 else {
                        logger.warning("[RPC] Receive: payload length is 0")
                        continue
                    }

                    let data = Data(bytes: UnsafeRawPointer(payloadPtr), count: Int(length))
                    self.handlePayload(op, data)
                } catch {
                    logger.error("[RPC] Receive: failed with error: \(error.localizedDescription)")
                }
            }
        }
    }

    private func handlePayload(_ opCode: OPCode, _ data: Data) {
        do {
            switch opCode {
            case .close:
                self.closeSocket()
                let eventClose = try EventClose.from(data: data)
                self.handlerWorker.async { [unowned self] in
                    self.disconnectHandler?(self, eventClose)
                }

            case .ping:
                try? self.send(String(data: data, encoding: .utf8)!, .pong)

            case .frame:
                let frame = try Frame.from(data: data)
                if frame.cmd == .dispatch || frame.evt == .error {
                    handleEvent(data)
                } else {
                    handleResponse(data)
                }

            default:
                logger.warning("""
                    HandlePayload: received unexpected opcode (\(opCode.rawValue)) \
                    with data: \(String(data: data, encoding: .utf8) ?? "nil")
                """)
                return
            }
        } catch {
            logger.error("""
                HandlePayload: failed with error: \(error.localizedDescription); \
                and data: \(String(data: data, encoding: .utf8) ?? "nil")
            """)
        }
    }

    private func handleResponse(_ data: Data) {
        do {
            let frame = try Frame.from(data: data)
            if try isNonceAsync(nonce: frame.nonce!) {
                self.handlerWorker.async { [unowned self] in
                    self.responseHandler?(self, frame.nonce!, frame.cmd, data)
                }
            } else {
                self.cmdNotifCenter.post(
                    name: NSNotification.Name(frame.nonce!),
                    object: nil,
                    userInfo: ["data": data, "error": false]
                )
            }
        } catch {
            logger.error("""
                HandleResponse: failed with error: \(error.localizedDescription); \
                and data: \(String(data: data, encoding: .utf8) ?? "nil")
            """)
        }
    }

    private func handleEvent(_ data: Data) {
        do {
            let frame = try Frame.from(data: data)

            switch frame.evt {
            case .ready:
                let readyEvent = try EventReady.from(data: data)
                self.handlerWorker.async { [unowned self] in
                    self.connectHandler?(self, readyEvent)
                }

            case .error:
                if try isNonceAsync(nonce: frame.nonce!) {
                    let err = try EventError.from(data: data)
                    self.handlerWorker.async { [unowned self] in
                        self.errorHandler?(self, frame.nonce!, err)
                    }
                } else {
                    self.cmdNotifCenter.post(
                        name: NSNotification.Name(frame.nonce!),
                        object: nil,
                        userInfo: ["data": data, "error": true]
                    )
                }

            default:
                self.handlerWorker.async { [unowned self] in
                    self.eventHandler?(self, frame.evt!, data)
                }
            }
        } catch {
            logger.error("""
                HandleEvent: failed with error: \(String(describing: error)); \
                and data: \(String(data: data, encoding: .utf8) ?? "nil")
            """)
            
            print(String(describing: error))
        }
    }
}
