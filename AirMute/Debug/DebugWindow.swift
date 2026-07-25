import AppKit
import SwiftUI

let windowDelegate = WindowDelegate()

private class DebugWindow: NSWindow {
    override var canBecomeKey: Bool { return true }
    override var canBecomeMain: Bool { return true }
    
    convenience init(viewController: NSViewController) {
        self.init(contentViewController: viewController)
        super.styleMask = [.titled, .closable, .fullSizeContentView]
        super.setContentSize(.init(width: 572, height: 458))
        super.title = String(localized: "Debug")
        super.center()
    }
}


func openDebugWindow() {
    let storyboard = NSStoryboard(name: "DebugWindow", bundle: nil)
    if let viewController = storyboard.instantiateController(withIdentifier: "DebugHostingController") as? NSHostingController<DebugViewContainer> {
        guard !windowDelegate.isOpen else {
            NSApp.activate()
            NSApp.keyWindow?.orderFrontRegardless()
            return
        }
        
        let window = DebugWindow(viewController: viewController)
        window.delegate = windowDelegate
        
        let windowController = NSWindowController(window: window)
        windowController.showWindow(nil)
        windowDelegate.isOpen = true
        windowController.window!.makeKey()
        NSApp.activate()
        NSApp.keyWindow?.orderFrontRegardless()
    }
}
