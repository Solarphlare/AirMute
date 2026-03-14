import AppKit

extension AppDelegate {
    func initObservers(_ rpc: RPC) {
        NSWorkspace.shared.notificationCenter.addObserver(forName: NSWorkspace.didLaunchApplicationNotification, object: nil, queue: nil) { notif in
            if let app = notif.userInfo?[NSWorkspace.applicationUserInfoKey] as? NSRunningApplication {
                if app.bundleIdentifier == "com.hnc.Discord" {
                    self.statusItemTitle = String(localized: "Trying to connect...")
                    logger.info("Discord is open.")
                    
                    Task {
                        for i in 1...30 {
                            do {
                                try rpc.connect()
                                break
                            }
                            catch {
                                logger.error("[RPC] Connection process threw an exception: \(String(describing: error))")
                                try? await Task.sleep(nanoseconds: 5_000_000_000 * UInt64(i))
                            }
                            
                            if rpc.user == nil {
                                self.statusItemTitle = String(localized: "Can't Connect to Discord")
                                logger.info("[RPC] Failed to connect: user is nil?")
                            }
                        }
                    }
                }
            }
        }
        
        NSWorkspace.shared.notificationCenter.addObserver(forName: NSWorkspace.didTerminateApplicationNotification, object: nil, queue: nil) { notif in
            if let app = notif.userInfo?[NSWorkspace.applicationUserInfoKey] as? NSRunningApplication {
                if app.bundleIdentifier == "com.hnc.Discord" {
                    self.statusItemTitle = String(localized: "Inactive — Discord Not Open")
                    self.controller?.stop()
                    self.rpc?.closeSocket()
                }
            }
        }
    }
}
