import SwiftUI
import ServiceManagement

struct BehaviorSettingsView: View {
    @AppStorage("click_to_undeafen") private var clickToUndeafen = true
    @State private var clickToUndeafenStateVar = UserDefaults.standard.object(forKey: "click_to_undeafen") as? Bool ?? true
    @EnvironmentObject private var appDelegate: AppDelegate
    @State private var programaticallyChangingStartupSwitch = false
    @State private var launchOnStartup = SMAppService.mainApp.status == .enabled
    
    var body: some View {
        Form {
            Section {
                Toggle(isOn: $clickToUndeafen) {
                    VStack(alignment: .leading, spacing: 2.5) {
                        Text("Click to Undeafen")
                        Text(getClickToDeafenText())
                            .font(.system(size: 11))
                            .foregroundStyle(.secondary)
                        
                    }
                }
                .onChange(of: clickToUndeafen) {
                    withAnimation { clickToUndeafenStateVar = clickToUndeafen }
                }
                
                Toggle(isOn: $launchOnStartup) {
                    Text("Launch on Startup")
                }
            }
            .animation(.default, value: clickToUndeafen)
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
    
    func getClickToDeafenText() -> String {
        var actionText = "clicking the stem or pressing the digital crown"
        let connectedAirPodsModels = appDelegate.connectedAirPodsVariants
        
        if connectedAirPodsModels.contains(.pro) || connectedAirPodsModels.contains(.base), connectedAirPodsModels.contains(.max) {
            actionText = "clicking the stem or pressing the digital crown"
        }
        else if (connectedAirPodsModels.count == 1) {
            if connectedAirPodsModels.contains(.pro) || connectedAirPodsModels.contains(.base) {
                actionText = "clicking the stem"
            }
            else if connectedAirPodsModels.contains(.max) {
                actionText = "pressing the digital crown"
            }
        }
        
        
        return clickToUndeafenStateVar ? "When deafened, \(actionText) will undeafen and unmute you." : "When deafened, \(actionText) will not do anything."
    }
}

#Preview {
    BehaviorSettingsView()
}
