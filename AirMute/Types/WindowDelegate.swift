import Foundation
import AppKit

class WindowDelegate: NSObject, NSWindowDelegate {
    var isOpen = false
    
    func windowWillClose(_ notification: Notification) {
        self.isOpen = false
    }
}
