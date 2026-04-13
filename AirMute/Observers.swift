import AppKit
import AVFoundation

extension AppDelegate {
    func initObservers(_ rpc: RPC) {
        NSWorkspace.shared.notificationCenter.addObserver(forName: NSWorkspace.didLaunchApplicationNotification, object: nil, queue: nil) { notif in
            if let app = notif.userInfo?[NSWorkspace.applicationUserInfoKey] as? NSRunningApplication {
                if app.bundleIdentifier == "com.hnc.Discord" {
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
                    rpc.closeSocket()
                }
            }
        }
        
        NSWorkspace.shared.notificationCenter.addObserver(forName: NSWorkspace.willSleepNotification, object: nil, queue: nil) { _ in
            self.statusItemTitle = String(localized: "Inactive — System Asleep")
            self.controller?.stop()
            rpc.closeSocket()
        }
        
        NSWorkspace.shared.notificationCenter.addObserver(forName: NSWorkspace.didWakeNotification, object: nil, queue: nil) { _ in
            guard let _ = AVCaptureDevice.default(for: .audio) else {
                self.isMicrophoneConnected = false
                return
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now().advanced(by: .seconds(15))) {
                if NSRunningApplication.runningApplications(withBundleIdentifier: "com.hnc.Discord").isEmpty {
                    self.statusItemTitle = String(localized: "Inactive — Discord Not Open")
                }
                else {
                    self.controller?.start()
                    self.connectToDiscord(rpc)
                }
            }
        }
    }
}
