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
    static func checkForUpdates() async {
        guard !UserDefaults.standard.bool(forKey: "update_available") else { return }
        
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
            latestVersionName.removeFirst()
            
            guard let installedVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String else {
                throw UpdateError.runtimeError("Failed to get installed version number")
            }
            
            let latestVersionSplit = latestVersionName.split(separator: ".").compactMap({ i in Int(i) })
            let installedVersionSplit = installedVersion.split(separator: ".").compactMap({ i in Int(i) })
            
            guard latestVersionSplit.count > 0, installedVersionSplit.count > 0, installedVersionSplit.count == latestVersionSplit.count else {
                throw UpdateError.runtimeError("Version splits either were empty or malformed")
            }
            
            var updateAvailable = false
            
            for i in 0..<installedVersionSplit.count {
                if latestVersionSplit[i] > installedVersionSplit[i] {
                    updateAvailable = true
                    break
                }
            }
            
            guard updateAvailable else {
                logger.info("[UpdateChecker] No updates available.")
                return
            }
            
            UserDefaults.standard.set(true, forKey: "update_available")
            UserDefaults.standard.set(latestVersionSplit, forKey: "latest_version")
            
            logger.info("[UpdateChecker] Update available: \(latestVersionName)")
            
            let delegate = await NSApplication.shared.delegate as! AppDelegate
            delegate.updateMenuItem.isHidden = false
        }
        catch {
            logger.error("[UpdateChecker] Failed to check for updates: \(String(describing: error))")
        }
    }
}
