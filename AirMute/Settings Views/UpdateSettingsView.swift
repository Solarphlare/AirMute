import SwiftUI

struct UpdateSettingsView: View {
    @Environment(\.openURL) private var openURL
    
    var body: some View {
        Form {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("A new version of AirMute is available.")
                    Text("If you've installed AirMute trough Homebrew Cask, please update from there.")
                        .foregroundStyle(.secondary)
                        .font(.system(size: 11))
                }
                Spacer()
                VStack(alignment: .trailing) {
                    Button {
                        
                    } label: {
                        Text("Download...")
                    }
                    Spacer()
                }
            }
        }
        .formStyle(.grouped)
    }
}

#Preview {
    UpdateSettingsView()
}
