import SwiftUI

struct GeneralSettingsView: View {
    @AppStorage("client_id") private var clientId = ""
    @AppStorage("client_secret") private var clientSecret = ""
    @FocusState private var focusState: FocusedField?
    
    var body: some View {
        Form {
            Section {
                TextField(text: $clientId) {
                    Text("Client ID")
                }
                .speechSpellsOutCharacters()
                .focused($focusState, equals: .id)
                
                TextField(text: $clientSecret) {
                    Text("Client Secret")
                }
                .speechSpellsOutCharacters()
                .focused($focusState, equals: .secret)
                
                VStack(alignment: .leading) {
                    if #available(macOS 15, *) {
                        HStack(spacing: 1) {
                            Text("You can obtain a Client ID and secret from the ")
                            Text("[Discord Developer Portal](https://discord.com/developers/applications).")
                                .pointerStyle(.link)
                        }
                    }
                    else {
                        Text("You can obtain a Client ID and secret from the [Discord Developer Portal](https://discord.com/developers/applications).")
                    }
                    
                    Text("Changes to the above values will require you to relaunch the app.")
                }
                .multilineTextAlignment(.leading)
                .font(.system(size: 11))
                .foregroundStyle(.secondary)
            }
        }
        .formStyle(.grouped)
    }
}

struct GeneralSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        GeneralSettingsView()
    }
}

fileprivate enum FocusedField {
    case id, secret, dud
}
