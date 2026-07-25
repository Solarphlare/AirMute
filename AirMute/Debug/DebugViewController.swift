import AppKit

import SwiftUI

class DebugViewController: NSHostingController<DebugViewContainer> {
    required init?(coder: NSCoder) {
        super.init(coder: coder, rootView: DebugViewContainer())
        self.sizingOptions = .intrinsicContentSize
    }
}
