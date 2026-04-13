import AppKit

extension AppDelegate {
    func initObservers(_ rpc: RPC) {
        NSWorkspace.shared.notificationCenter.addObserver(forName: NSWorkspace.didLaunchApplicationNotification, object: nil, queue: nil) { notif in
            if let app = notif.userInfo?[NSWorkspace.applicationUserInfoKey] as? NSRunningApplication {
                if app.bundleIdentifier == "com.hnc.Discord" {
                    self.statusItemTitle = String(localized: "Trying to connect...")
                    logger.info("Discord is open.")
                    self.connectToDiscord(rpc)
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
