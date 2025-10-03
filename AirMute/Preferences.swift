import Foundation
import AppKit
import SwiftUI
import ServiceManagement

extension AppDelegate {
    func migrateToSMAppService() {
        if !UserDefaults.standard.bool(forKey: "migrated_to_service_management") {
            if UserDefaults.standard.bool(forKey: "launch_on_startup") {
                let launchAgentFile = FileManager.default.homeDirectoryForCurrentUser.appending(path: "Library/LaunchAgents/AirMute.plist")
                do {
                    if FileManager.default.fileExists(atPath: launchAgentFile.path(percentEncoded: false)) {
                        try FileManager.default.removeItem(at: launchAgentFile)
                    }
                    try SMAppService.mainApp.register()
                    UserDefaults.standard.set(true, forKey: "migrated_to_service_management")
                    UserDefaults.standard.removeObject(forKey: "launch_on_startup")
                    logger.info("Successfully migrated login task to SMAppService.")
                }
                catch {
                    logger.info("Failed to migrate login task to SMAppService.")
                    return
                }
            }
            
            UserDefaults.standard.set(true, forKey: "migrated_to_service_management")
        }
    }

    @objc func launchPreferences() {
        let storyboard = NSStoryboard(name: "Main", bundle: nil)
        if let viewController = storyboard.instantiateController(withIdentifier: "PreferencesHostingController") as? NSHostingController<SettingsView> {
            guard !windowDelegate.isOpen else {
                NSApp.activate()
                NSApp.keyWindow?.orderFrontRegardless()
                return
            }
            
            let window = NSWindow(contentViewController: viewController)
            
            window.styleMask = [.titled, .closable]
            window.title = "AirMute — Settings"
            if UserDefaults.standard.bool(forKey: "update_available") && rpc?.user != nil {
                window.setContentSize(.init(width: 550, height: 400))
            }
            else {
                window.setContentSize(.init(width: 550, height: 380))
            }
            window.center()
            
            window.delegate = windowDelegate
            
            let windowController = NSWindowController(window: window)
            windowController.showWindow(self)
            windowDelegate.isOpen = true
            windowController.window!.makeKey()
            NSApp.activate()
            NSApp.keyWindow?.orderFrontRegardless()
            return
        }
    }
}
