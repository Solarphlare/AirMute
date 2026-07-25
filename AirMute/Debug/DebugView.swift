import SwiftUI
import AVFoundation
import CoreBluetooth

struct DebugView: View {
    @Environment(\.openURL) private var openURL
    @EnvironmentObject private var appDelegate: AppDelegate
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("State")) {
                    LabeledContent("Compatible AirPods Available") {
                        Text(String(describing: !appDelegate.connectedAirPodsModels.subtracting(unsupportedRegularAirPodsModels).isEmpty))
                    }
                    LabeledContent("Audio Input Device Available") {
                        Text("\(String(describing: appDelegate.isMicrophoneConnected)) \(appDelegate.isMicrophoneConnected ? "(\(AVCaptureDevice.default(for: .audio)!.localizedName))" : "")")
                    }
                    LabeledContent("Bluetooth Permission State") {
                        Text(getAuthorizationStatusName(for: CBCentralManager.authorization))
                    }
                    LabeledContent("Connected to Discord") {
                        Text(String(describing: appDelegate.connectedToDiscord))
                    }
                }
                Section(header: Text("Connected Devices")) {
                    LabeledContent("Connected AirPods Variants") {
                        Text(appDelegate.connectedAirPodsVariants.isEmpty ? "None" : appDelegate.connectedAirPodsVariants.map(\.rawValue).joined(separator: ", "))
                    }
                    LabeledContent("Connected AirPods Models") {
                        Text(appDelegate.connectedAirPodsModels.isEmpty ? "None" : appDelegate.connectedAirPodsModels.map(String.init(describing:)).joined(separator: ", "))
                    }
                }
                
                Section {
                    NavigationLink(value: true, label: {
                        VStack(alignment: .leading) {
                            Text("Open Log File")
                        }
                    })
                    .simultaneousGesture(TapGesture().onEnded {
                        NSWorkspace.shared.open(AppLogger.logFile)
                        
                    })
                }
            }
            .formStyle(.grouped)
        }
    }
}

struct DebugViewContainer: View {
    var body: some View {
        DebugView()
            .environmentObject(NSApplication.shared.delegate as! AppDelegate)
    }
}

func getAuthorizationStatusName(for status: CBManagerAuthorization) -> String {
    switch status {
    case .notDetermined: return "notDetermined"
    case .restricted: return "restricted"
    case .denied: return "denied"
    case .allowedAlways: return "allowedAlways"
    @unknown default: return "unknown"
    }
}
