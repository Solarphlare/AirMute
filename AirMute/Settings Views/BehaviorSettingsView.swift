import SwiftUI
import ServiceManagement

struct BehaviorSettingsView: View {
    @AppStorage("click_to_undeafen") private var clickToUndeafen = true
    @State private var programaticallyChangingStartupSwitch = false
    @State private var launchOnStartup = SMAppService.mainApp.status == .enabled
    
    var body: some View {
        Form {
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
        .onChange(of: launchOnStartup) {
            guard !programaticallyChangingStartupSwitch else { return }
            programaticallyChangingStartupSwitch = true
            
            if launchOnStartup {
                do {
                    try SMAppService.mainApp.register()
                }
                catch {
                    launchOnStartup = false
                }
            }
            else {
                do {
                    try SMAppService.mainApp.unregister()
                }
                catch {
                    launchOnStartup = true
                }
            }
            
            programaticallyChangingStartupSwitch = false
        }
    }
}

#Preview {
    BehaviorSettingsView()
}
