import SwiftUI

@Observable class BackStack {
    var history = [SettingsPage.general]
    var index = 0
    
    func navigate(to page: SettingsPage) {
        if (history.count > 0) {
            if history[index] == page { return }
            
            if index < history.count - 1 {
                history.removeSubrange((index + 1) ..< history.count)
            }
        }
        
        history.append(page)
        index = history.count - 1
    }
    
    func navigateBack() -> SettingsPage {
        index -= 1
        return history[index]
    }
    
    func navigateForward() -> SettingsPage {
        index += 1
        return history[index]
    }
}
