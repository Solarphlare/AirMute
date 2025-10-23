import AppKit

class SettingsWindow: NSWindow {
    override var canBecomeKey: Bool { return true }
    override var canBecomeMain: Bool { return true }
    
    convenience init(viewController: NSViewController) {
        self.init(contentViewController: viewController)
        super.styleMask = [.titled, .closable, .fullSizeContentView]
        super.setContentSize(.init(width: 650, height: 520))
        super.title = String(localized: "General")
        super.center()
    }
}
