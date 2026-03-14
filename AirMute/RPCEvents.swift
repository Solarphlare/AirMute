import Foundation
import AVFAudio

extension AppDelegate {
    func initRPCEvents(_ rpc: RPC) {
        rpc.onConnect { rpcParam, event in
            do {
                let authentication = try rpcParam.authenticateOverRPC()
                
                rpc.user = authentication.data.user
                logger.info("[RPC] Connected to @\(authentication.data.user.username)!")
                
                self.statusItemTitle = "Inactive — Not in Voice"
                
                _ = try rpcParam.subscribe(event: .voiceConnectionStatus)
                logger.info("[RPC] Successfully registered subscription for event type \(EventType.voiceConnectionStatus.rawValue)")
                _ = try rpcParam.subscribe(event: .voiceSettingsUpdate)
                logger.info("[RPC] Successfully registered subscription for event type \(EventType.voiceSettingsUpdate.rawValue)")
                
                try self.initMuteStateHandler(rpcParam)
                
                self.cancellable = NotificationCenter.default.publisher(for: AVAudioApplication.inputMuteStateChangeNotification)
                    .sink { notification in
                        // pass
                    }
            }
            catch HTTPError.failed(let code, let error) {
                if (code == 401) {
                    self.statusItemTitle = "Error — Invalid Client Secret"
                    logger.error("[RPC] Failed to connect - client secret is invalid")
                    rpc.closeSocket()
                }
                else {
                    self.statusItemTitle = "Error — Unable to Connect"
                    logger.error("[RPC] Got HTTP error \(code ?? -1): \(String(describing: error))")
                }
            }
            catch CommandError.failed(let code, let errorMessage) {
                if code == .oAuth2Error {
                    self.statusItemTitle = "Error — Couldn't Obtain Authorization"
                    logger.error("[RPC] Failed to connect - couldn't obtain authorization")
                }
                else {
                    self.statusItemTitle = "Error — Command Failed"
                    logger.error("[RPC] Got command error \(String(describing: code)): \(errorMessage)")
                }
            }
            catch {
                logger.error("[RPC] onConnect block error: \(String(describing: error))")
            }
        }
        
        rpc.onEvent { rpcParam, eventType, event in
            if eventType == .voiceSettingsUpdate {
                do {
                    let responseSvc = try ResponseGetVoiceSettings.from(data: event)
                    self.clientInitiatedAction = true
                    try AVAudioApplication.shared.setInputMuted(responseSvc.data.deaf || responseSvc.data.mute)
                }
                catch {
                    logger.error(String(describing: error))
                }
            }
            else if eventType == .voiceConnectionStatus {
                do {
                    let eventData = try EventVoiceConnectionStatus.from(data: event)
                    if eventData.data.state == .disconnected {
                        self.statusItemTitle = "Inactive — Not in Voice"
                        self.controller?.stop()
                    }
                    else {
                        self.statusItemTitle = "Active — In Voice"
                        self.controller?.start()
                    }
                }
                catch {
                    logger.error(String(describing: error))
                }
            }
        }
        
        rpc.onDisconnect { rpcParam, event in
            switch event.code {
            case .invalidClientID:
                self.statusItemTitle = "Error — Invalid Client ID"
                logger.error("[RPC] Failed to connect - Invalid Client ID: \(event.message)")
            case .invalidOrigin:
                self.statusItemTitle = "Error — Invalid RPC Origin"
                logger.error("[RPC] Failed to connect - Invalid RPC Origin: \(event.message)")
            case .socketDisconnected:
                self.statusItemTitle = "Error — Unable to Connect"
                logger.error("[RPC] Failed to connect - socket died (\(event.message))")
            default:
                self.statusItemTitle = "Error — Unable to Connect"
                logger.error("[RPC] Got disocnnect OpCode: \(event.code.rawValue) \(event.message)")
            }
        }
    }
}
