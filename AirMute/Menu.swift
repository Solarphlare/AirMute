import AppKit

extension AppDelegate {
    func makeMenu() {
        let menu = NSMenu()
        statusItem = NSMenuItem(title: statusItemTitle, action: nil, keyEquivalent: "")
        statusItem.isEnabled = false
        updateMenuItem.isHidden = !UserDefaults.standard.bool(forKey: "update_available")
        updateMenuItem.image = NSImage(systemSymbolName: "square.and.arrow.down", accessibilityDescription: nil)!
        
        menu.addItem(statusItem)
        menu.addItem(.separator())
        menu.addItem(updateMenuItem)
        
        let settingsMenuItem = NSMenuItem(title: String(localized: "Settings..."), action: #selector(launchPreferences), keyEquivalent: "")
        settingsMenuItem.image = NSImage(systemSymbolName: "gear", accessibilityDescription: nil)!
        
        menu.addItem(settingsMenuItem)
        
        let quitMenuItem = NSMenuItem(title: String(localized: "Quit"), action: #selector(NSApplication.terminate), keyEquivalent: "")
        
        if #unavailable(macOS 26.1) { // macOS 26.1+ includes a default icon for the quit MenuItem
            quitMenuItem.image = NSImage(systemSymbolName: "xmark.rectangle", accessibilityDescription: nil)!
        }
        
        menu.addItem(quitMenuItem)
        
        
        statusBarMenuItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        statusBarMenuItem.menu = menu
        
        let image = NSImage(systemSymbolName: "person.wave.2.fill", accessibilityDescription: nil)!
            .withSymbolConfiguration(
                .preferringHierarchical().applying(.init(textStyle: .body, scale: .medium).applying(.init(pointSize: 14, weight: .semibold)))
            )!
                
        image.size = NSSize(width: 24.0, height: 24.0)
        statusBarMenuItem.button!.image = image
        statusBarMenuItem.isVisible = true
    }
}
