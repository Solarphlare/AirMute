import Foundation
import AppKit

enum UpdateError: Error, CustomStringConvertible {
    case runtimeError(String)
    
    public var description: String {
        switch self {
        case .runtimeError(let description):
            return NSLocalizedString(description, comment: "")
        }
    }
}

struct UpdateChecker {
    static func parseVersion(_ versionString: String) -> [Int] {
        return versionString
            .split(separator: ".")
            .compactMap { component in
                let digits = component.prefix(while: { $0.isNumber })
                return Int(digits)
            }
    }

    static func isVersion(_ version: [Int], newerThan otherVersion: [Int]) -> Bool {
        for index in 0..<max(version.count, otherVersion.count) {
            let component = index < version.count ? version[index] : 0
            let otherComponent = index < otherVersion.count ? otherVersion[index] : 0

            if component != otherComponent {
                return component > otherComponent
            }
        }

        return false
    }

    static func checkForUpdates() async {
        do {
            let (data, response) = try await URLSession.shared.data(from: URL(string: "https://api.github.com/repos/Solarphlare/AirMute/releases")!)
            
            if (response as! HTTPURLResponse).statusCode != 200 {
                throw URLError(.badServerResponse)
            }

            let json = try JSONSerialization.jsonObject(with: data) as! [[String : Any]]
            
            guard json.count > 0 else { throw UpdateError.runtimeError("JSON array was empty") }
            
            let currentRelease = json[0]
            guard var latestVersionName = currentRelease["tag_name"] as? String else {
                throw UpdateError.runtimeError("Unable to get tag name")
            }
            if latestVersionName.lowercased().hasPrefix("v") {
                latestVersionName.removeFirst()
            }
            
            guard let installedVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String else {
                throw UpdateError.runtimeError("Failed to get installed version number")
            }
            
            let latestVersionSplit = parseVersion(latestVersionName)
            let installedVersionSplit = parseVersion(installedVersion)
            
            guard latestVersionSplit.count > 0, installedVersionSplit.count > 0 else {
                throw UpdateError.runtimeError("Version splits either were empty or malformed")
            }
            
            let delegate = await NSApplication.shared.delegate as? AppDelegate

            if isVersion(latestVersionSplit, newerThan: installedVersionSplit) {
                UserDefaults.standard.set(true, forKey: "update_available")
                UserDefaults.standard.set(latestVersionSplit, forKey: "latest_version")
                
                logger.info("[UpdateChecker] Update available: \(latestVersionName)")
                
                await MainActor.run {
                    delegate?.updateMenuItem.isHidden = false
                }
            }
            else {
                logger.info("[UpdateChecker] No updates available.")
                
                UserDefaults.standard.set(false, forKey: "update_available")
                UserDefaults.standard.removeObject(forKey: "latest_version")
                
                await MainActor.run {
                    delegate?.updateMenuItem.isHidden = true
                }
            }
        }
        catch {
            logger.error("[UpdateChecker] Failed to check for updates: \(String(describing: error))")
        }
    }
}
