import SwiftUI

struct SettingsSidebarView: View {
    @Binding var selectedPage: SettingsPage
    @AppStorage("update_available") private var updateAvailable = false
    let SIDEBAR_AVATAR_SIZE: CGFloat = 40
    
    var body: some View {
        let user = (NSApplication.shared.delegate as! AppDelegate).rpc?.user

        List(selection: $selectedPage) {
            Section {
                if let user {
                    HStack {
                        if let avatar = user.avatar {
                            let url = URL(string: "https://cdn.discordapp.com/avatars/\(user.id)/\(avatar).png?size=256")!
                            
                            CachedAsyncImage(url: url) {
                                $0.resizable()
                                    .clipShape(Circle())
                                    .frame(width: SIDEBAR_AVATAR_SIZE, height: SIDEBAR_AVATAR_SIZE)
                            } placeholder: {
                                Image(systemName: "person.crop.circle.fill")
                                    .font(.system(size: SIDEBAR_AVATAR_SIZE))
                                    .frame(width: SIDEBAR_AVATAR_SIZE, height: SIDEBAR_AVATAR_SIZE)
                            }
                        }
                        else {
                            Image(systemName: "person.crop.circle.fill")
                                .font(.system(size: SIDEBAR_AVATAR_SIZE))
                                .frame(width: SIDEBAR_AVATAR_SIZE, height: SIDEBAR_AVATAR_SIZE)
                        }
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(user.globalName ?? user.username)
                                .fontWeight(.semibold)
                                .font(.system(size: 13.5))
                            Text("@" + user.username)
                                .font(.system(size: 11.5))
                                .opacity(0.5)
                        }
                    }
                }
            }
    
            if updateAvailable {
                Section {
                        HStack {
                            Text("Update Available")
                            Spacer()
                            Text("1")
                                .padding(.all, 6)
                                .font(.system(size: 10, weight: .semibold))
                                .foregroundStyle(.white)
                                .background(Color.red)
                                .clipShape(Circle())
                        }
                        .tag(SettingsPage.update)
                    }
            }
            
            Section {
                Label(title: {
                    Text("General")
                }, icon: {
                    Image(systemName: "gear")
                })
                .tag(SettingsPage.general)
                
                Label(title: {
                    Text("Behavior")
                }, icon: {
                    Image(systemName: "rectangle.grid.1x2")
                })
                .tag(SettingsPage.behavior)
                
                Label(title: {
                    Text("About")
                }, icon: {
                    Image(systemName: "info.circle")
                })
                .tag(SettingsPage.about)
            }
        }
    }
}

#Preview {
    NavigationSplitView(sidebar: {
        SettingsSidebarView(selectedPage: .constant(.general))
    }, detail: {
        
    })
}
