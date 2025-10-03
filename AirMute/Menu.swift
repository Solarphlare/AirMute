import AppKit

extension AppDelegate {
    func makeMenu() {
        let menu = NSMenu()
        statusItem = NSMenuItem(title: statusItemTitle, action: nil, keyEquivalent: "")
        statusItem.isEnabled = false
        updateMenuItem.isHidden = !UserDefaults.standard.bool(forKey: "update_available")
        
        menu.addItem(statusItem)
        menu.addItem(updateMenuItem)
        menu.addItem(NSMenuItem(title: "Settings...", action: #selector(launchPreferences), keyEquivalent: ""))
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate), keyEquivalent: ""))
        
        
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
