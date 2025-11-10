import SwiftUI

struct SettingsDetailView: View {
    @Binding var selectedPage: SettingsPage
    
    var body: some View {
        switch (selectedPage) {
            case .about:
                AboutSettingsView()
                    .navigationTitle("About")
            case .behavior:
                BehaviorSettingsView()
                    .navigationTitle("Behavior")
            case .update:
                UpdateSettingsView()
                    .navigationTitle("Software Update")
            case .general:
                GeneralSettingsView()
                    .navigationTitle("General")
        }
    }
}

#Preview {
    SettingsDetailView(selectedPage: .constant(.general))
}
