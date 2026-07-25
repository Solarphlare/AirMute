import SwiftUI

enum SettingsPage {
    case general
    case behavior
    case about
    case update
}

struct SettingsView: View {
    @AppStorage("client_id") private var clientId = ""
    @AppStorage("client_secret") private var clientSecret = ""
    @AppStorage("click_to_undeafen") private var clickToUndeafen = true
    
    @State private var selectedPage: SettingsPage = .general
    @State private var backStack = BackStack()
    
    var body: some View {
        NavigationSplitView(sidebar: {
            SettingsSidebarView(selectedPage: $selectedPage)
                .toolbar(removing: .sidebarToggle)
                .toolbar {
                    ToolbarItem(placement: .navigation, content: {
                        Button {
                            selectedPage = backStack.navigateBack()
                        } label: {
                            Label(title: { Text("Back") }, icon: {
                                Image(systemName: "chevron.left")
                                    .padding(.horizontal, 2)
                            })
                        }
                        .disabled(backStack.index == 0)
                    })
                    ToolbarItem(placement: .navigation, content: {
                        Button {
                            selectedPage = backStack.navigateForward()
                        } label: {
                            Label(title: { Text("Forward") }, icon: { Image(systemName: "chevron.right")
                                .padding(.horizontal, 4)
                            })
                        }
                        .disabled(backStack.index == (backStack.history.count - 1))
                    })
                }
        }, detail: {
            SettingsDetailView(selectedPage: $selectedPage)
        })
        .onChange(of: selectedPage) {
            backStack.navigate(to: selectedPage)
        }
        .environmentObject(NSApplication.shared.delegate as! AppDelegate)
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
