import AppKit
import AVFAudio
import Combine
import AVFoundation

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    var controller: AudioInputController?
    var cancellable: AnyCancellable?
    var clientInitiatedAction = false
    var isMicrophoneConnected = false {
        didSet {
            if !isMicrophoneConnected {
                self.statusItem.title = String(localized: "Inactive — No Microphone Connected")
            }
            else {
                self.statusItem.title = self.statusItemTitle
            }
        }
    }
    
    var statusItemTitle = "Inactive — Discord Not Open" {
        didSet {
            if isMicrophoneConnected {
                self.statusItem.title = self.statusItemTitle
            }
        }
    }
    
    var statusBarMenuItem: NSStatusItem!
    var statusItem: NSMenuItem!
    var updateMenuItem = NSMenuItem(title: String(localized: "Install Update..."), action: #selector(openReleasesPage), keyEquivalent: "")
    
    var rpc: RPC?
    
    let windowDelegate = PreferencesWindowDelegate()
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        if UserDefaults.standard.bool(forKey: "update_available") {
            if let installedVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
                let installedVersionSplit = installedVersion.split(separator: ".").compactMap({ i in Int(i) })
                let latestVersionSplit = UserDefaults.standard.array(forKey: "latest_version") as! [Int]
            
                if latestVersionSplit.elementsEqual(installedVersionSplit) {
                    logger.info("App was updated since last launch")
                    UserDefaults.standard.set(false, forKey: "update_available")
                }
            }
        }
        
        migrateToSMAppService()
        makeMenu()
        
        let clientId = UserDefaults.standard.string(forKey: "client_id")?.trimmingCharacters(in: .whitespacesAndNewlines)
        let clientSecret = UserDefaults.standard.string(forKey: "client_secret")?.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if clientId == nil || clientId!.isEmpty || clientSecret == nil || clientSecret!.isEmpty {
            statusItemTitle = String(localized: "Inactive — Missing Settings Values")
            logger.error("Missing settings values.")
            return
        }
        
        if UserDefaults.standard.value(forKey: "click_to_deafen") == nil {
            UserDefaults.standard.set(true, forKey: "click_to_deafen")
        }
        
        if AVCaptureDevice.default(for: .audio) != nil {
            isMicrophoneConnected = true
            controller = AudioInputController()
        }
        
        let rpc = RPC(clientId: clientId!, clientSecret: clientSecret!)
        self.rpc = rpc

        initRPCEvents(rpc)
        initObservers(rpc)
        
        if !NSRunningApplication.runningApplications(withBundleIdentifier: "com.hnc.Discord").isEmpty {
            connectToDiscord(rpc)
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(audioCaptureDeviceConnected), name: AVCaptureDevice.wasConnectedNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(audioCaptureDeviceWasDisconnected), name: AVCaptureDevice.wasDisconnectedNotification, object: nil)
        
        if !UserDefaults.standard.bool(forKey: "update_available") {
            let timer = Timer.scheduledTimer(withTimeInterval: 60 * 60 * 6, repeats: true) { _ in
                Task {
                    await UpdateChecker.checkForUpdates()
                }
            }
            
            timer.fire()
        }
    }
    
    func connectToDiscord(_ rpc: RPC) {
        self.statusItemTitle = String(localized: "Trying to connect...")
        
        Task {
            for i in 1...30 {
                do {
                    try rpc.connect()
                    break
                }
                catch {
                    logger.error("[RPC] Connection process threw an exception: \(String(describing: error))")
                    try? await Task.sleep(nanoseconds: 5_000_000_000 * UInt64(i))
                }
                
                if rpc.user == nil {
                    self.statusItemTitle = String(localized: "Can't Connect to Discord")
                    logger.info("[RPC] Failed to connect: user is nil?")
                }
            }
        }
    }
    
    @objc func audioCaptureDeviceConnected(notification: Notification) {
        guard let device = notification.object as? AVCaptureDevice, device.hasMediaType(.audio) else {
            return
        }
        
        if (isMicrophoneConnected) { return }
        
        logger.info("An audio capture device was connected.")
        isMicrophoneConnected = true
        controller = AudioInputController()
        
        if (try? rpc?.getSelectedVoiceChannel()) != nil {
            controller?.start()
        }
    }
    
    @objc func audioCaptureDeviceWasDisconnected(notification: Notification) {
        guard let device = notification.object as? AVCaptureDevice, device.hasMediaType(.audio) else {
            return
        }
        
        if AVCaptureDevice.default(for: .audio) == nil {
            logger.info("An audio capture device was disconnected, and none are left.")
            isMicrophoneConnected = false
            controller?.stop()
            controller = nil
        }
    }
    
    @objc func openReleasesPage() {
        NSWorkspace.shared.open(URL(string: "https://github.com/Solarphlare/AirMute/releases/latest")!)
    }
    
    
    @IBAction func menuItemClicked(_ sender: NSMenuItem) {
        if (sender.tag == 1) {
            NSWorkspace.shared.open(URL(string: "https://www.youtube.com/watch?v=FtutLA63Cp8")!)
        }
        else if (sender.tag == 2) {
            NSWorkspace.shared.open(URL(string: "https://www.youtube.com/watch?v=sqK-jh4TDXo")!)
        }
    }
    
    
    func applicationWillTerminate(_ aNotification: Notification) {
        rpc?.closeSocket()
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }
}

