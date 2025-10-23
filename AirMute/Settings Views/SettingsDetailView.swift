import SwiftUI

struct SettingsDetailView: View {
    @Binding var selectedPage: SettingsPage
    
    var body: some View {
        if selectedPage == .about {
            AboutSettingsView()
                .navigationTitle("About")
        }
        else if selectedPage == .behavior {
            BehaviorSettingsView()
                .navigationTitle("Behavior")
        }
        else {
            GeneralSettingsView()
                .navigationTitle("General")
        }
    }
}

#Preview {
    SettingsDetailView(selectedPage: .constant(.general))
}
