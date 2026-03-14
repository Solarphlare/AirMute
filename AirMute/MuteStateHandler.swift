import AVFAudio

extension AppDelegate {
    func initMuteStateHandler(_ rpc: RPC) throws {
        logger.info("Registering input mute state change handler")
        
        try AVAudioApplication.shared.setInputMuteStateChangeHandler { isMuted in
            #if DEBUG
            logger.info("[MuteStateHandler] Got input mute state change \(self.clientInitiatedAction ? "from Discord" : "from audio device"): isMuted=\(isMuted)")
            #endif
            
            if self.clientInitiatedAction {
                self.clientInitiatedAction = false
                return true
            }
            
            guard let voiceSettings = try? rpc.getVoiceSettings() else {
                logger.error("[MuteStateHandler] Failed to get voice settings.")
                return false
            }
            
            if voiceSettings.data.deaf {
                if isMuted { return true }
                
                if UserDefaults.standard.bool(forKey: "click_to_undeafen") {
                    do {
                        try rpc.setMicMuted(isMuted)
                        return true
                    }
                    catch {
                        logger.error("[MuteStateHandler] Unable to change mute state for Discord client: \(String(describing: error))")
                        return false
                    }
                }
                else { return false }
            }
            
            do {
                try rpc.setMicMuted(isMuted)
                return true
            }
            catch {
                logger.error("Unable to change mute state for Discord client: \(String(describing: error))")
                return false
            }
        }
    }
}
