import SwiftUI
import Foundation

struct AboutSettingsView: View {
    @Environment(\.openURL) private var openURL
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    VStack(alignment: .center, spacing: 12) {
                        Image("AirMute")
                            .resizable()
                            .frame(width: 70, height: 70)
                        VStack {
                            Text("AirMute")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                            Text("By Solarphlare")
                                .foregroundStyle(.secondary)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 8)
                }
                Section {
                    LabeledContent(content: {
                        Text("\(Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String) (\(Bundle.main.infoDictionary!["CFBundleVersion"] as! String))")
                    }, label: {
                        Text("Version")
                    })
                    LabeledContent(content: {
                        Text("© \(String(Calendar.current.component(.year, from: Date.now))) Solarphlare")
                    }, label: {
                        Text("Copyright")
                    })
                    NavigationLink(value: true, label: {
                        VStack(alignment: .leading, spacing: 1) {
                            Text("View GitHub Repository")
                            Text("Solarphlare/AirMute")
                                .font(.system(size: 11))
                                .foregroundStyle(.secondary)
                        }
                    })
                    .simultaneousGesture(TapGesture().onEnded {
                        openURL(URL(string: "https://github.com/Solarphlare/AirMute")!)
                    })
                }
                
                Section {
                    NavigationLink(value: true, label: {
                        VStack(alignment: .leading, spacing: 1) {
                            Text("View License")
                            Text("Licensed Under GNU GPLv3")
                                .font(.system(size: 11))
                                .foregroundStyle(.secondary)
                        }
                    })
                    .simultaneousGesture(TapGesture().onEnded {
                        openURL(URL(string: "https://github.com/Solarphlare/AirMute/blob/master/LICENSE")!)
                    })
                } header: {
                    Text("Legal")
                }
            }
            .formStyle(.grouped)
        }
    }
}

#Preview {
    AboutSettingsView()
}
