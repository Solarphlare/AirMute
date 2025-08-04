import SwiftUI

struct SettingsView: View {
    @AppStorage("client_id") private var clientId = ""
    @AppStorage("client_secret") private var clientSecret = ""
    @AppStorage("click_to_undeafen") private var clickToUndeafen = true
    @AppStorage("launch_on_startup") private var launchOnStartup = false
    @AppStorage("update_available") private var updateAvailable = false
    
    @Environment(\.openURL) private var openURL
    @FocusState private var focusState: FocusedField?
    
    var body: some View {
        let user = (NSApplication.shared.delegate as! AppDelegate).rpc?.user
        
        VStack {
            Form {
                if user != nil || updateAvailable {
                    Section {
                        if let user {
                            HStack {
                                if let avatar = user.avatar {
                                    let url = URL(string: "https://cdn.discordapp.com/avatars/\(user.id)/\(avatar).png?size=256")!
                                    
                                    AsyncImage(url: url) {
                                        $0.resizable()
                                            .clipShape(Circle())
                                            .frame(width: 30, height: 30)
                                    } placeholder: {
                                        Image(systemName: "person.crop.circle.fill")
                                            .font(.system(size: 30))
                                            .frame(width: 30, height: 30)
                                    }
                                }
                                else {
                                    Image(systemName: "person.crop.circle.fill")
                                        .font(.system(size: 30))
                                        .frame(width: 30, height: 30)
                                }
                                
                                VStack(alignment: .leading) {
                                    Text(user.globalName)
                                        .fontWeight(.semibold)
                                    Text("@" + user.username)
                                        .font(.system(size: 11.5))
                                        .opacity(0.5)
                                }
                            }
                        }
                        if updateAvailable {
                            HStack {
                                Text("A newer version of AirMute is available.")
                                Spacer()
                                Button(action: { openURL(URL(string: "https://github.com/Solarphlare/AirMute/releases/latest")!) }) {
                                    Text("Update...")
                                }
                            }
                        }
                    }
                }
                
                Section {
                    TextField(text: $clientId) {
                        Text("Client ID")
                    }
                    .focused($focusState, equals: .id)
                    
                    TextField(text: $clientSecret) {
                        Text("Client Secret")
                    }
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
                
                Section {
                    Toggle(isOn: $clickToUndeafen) {
                        VStack(alignment: .leading, spacing: 2.5) {
                            Text("Click to Undeafen")
                            Text(clickToUndeafen ? "When deafened, clicking the stem or pressing the digital crown will undeafen and unmute you." : "When deafened, clicking the stem or pressing the digital crown will not do anything.")
                                .font(.system(size: 11))
                                .foregroundStyle(.secondary)
                            
                        }
                    }
                    
                    Toggle(isOn: $launchOnStartup) {
                        Text("Launch on Startup")
                    }
                }
                
            }
            .formStyle(.grouped)
            .scrollDisabled(true)
            
            Spacer()
            
            Text("AirMute \(Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String) (\(Bundle.main.infoDictionary!["CFBundleVersion"] as! String))")
                .padding(.bottom, 12)
                .foregroundStyle(Color(nsColor: .tertiaryLabelColor))
                .font(.system(size: 11))
        }
        .onChange(of: launchOnStartup) {
            launchOnStartupStateChanged(to: launchOnStartup)
        }
        .onAppear {
            // Wrangling the default SwiftUI focus
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.001) {
                focusState = nil
            }
        }
    }
}

fileprivate enum FocusedField {
    case id, secret, dud
}

#Preview {
    SettingsView()
}
