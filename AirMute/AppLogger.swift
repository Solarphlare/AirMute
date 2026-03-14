import Foundation
import os
import AppKit

class AppLogger {
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "AirMute", category: "AirMute-UserLogs")
    fileprivate static let logFile = FileManager.default.homeDirectoryForCurrentUser.appending(path: "Library/Logs/AirMute.log", directoryHint: .notDirectory)
    
    private var fileHandle: FileHandle?
    
    func info(_ message: String) {
        recreateLogFileIfNecessary()
        
        if let fileHandle {
            if let _ = try? fileHandle.seekToEnd(), let data = "\(Date.now) [INFO] \(message)\n".data(using: .utf8) {
                fileHandle.write(data)
            }
        }
        
        logger.info("\(message)")
    }
    
    func warning(_ message: String) {
        recreateLogFileIfNecessary()
        
        if let fileHandle {
            if let _ = try? fileHandle.seekToEnd(), let data = "\(Date.now) [WARNING] \(message)\n".data(using: .utf8) {
                fileHandle.write(data)
            }
        }
        
        logger.warning("\(message)")
    }
    
    func error(_ message: String) {
        recreateLogFileIfNecessary()
        
        if let fileHandle {
            if let _ = try? fileHandle.seekToEnd(), let data = "\(Date.now) [ERROR] \(message)\n".data(using: .utf8) {
                fileHandle.write(data)
            }
        }
        
        logger.error("\(message)")
    }
    
    init() {
        if FileManager.default.fileExists(atPath: Self.logFile.path()) {
            try? FileManager.default.removeItem(at: Self.logFile)
        }
        
        FileManager.default.createFile(atPath: Self.logFile.path(), contents: nil, attributes: nil)
        
        do {
            self.fileHandle = try FileHandle(forWritingTo: Self.logFile)
        }
        catch {
            self.fileHandle = nil
            logger.error("Failed to initialise FileHandle for log file, no subsequent logs will be written to disk")
        }
    }
    
    private func recreateLogFileIfNecessary() {
        if !FileManager.default.fileExists(atPath: Self.logFile.path()) {
            FileManager.default.createFile(atPath: Self.logFile.path(), contents: nil, attributes: nil)
        }
        
        guard let attributes = try? FileManager.default.attributesOfItem(atPath: Self.logFile.path()) else { return }
        
        if let size = attributes[.size] as? UInt64, size >= 100_000_000 {
            guard let _ = try? FileManager.default.removeItem(at: Self.logFile) else { return }
            self.fileHandle = nil
            FileManager.default.createFile(atPath: Self.logFile.path(), contents: nil, attributes: nil)
            
            do {
                self.fileHandle = try FileHandle(forWritingTo: Self.logFile)
            }
            catch {
                self.fileHandle = nil
                logger.error("Failed to initialise FileHandle for log file, no subsequent logs will be written to disk")
            }
        }
    }
}

extension AppDelegate {
    @objc func saveLogFileToDesktop() {
        let desktopDirectory = FileManager.default.homeDirectoryForCurrentUser.appending(path: "Desktop")
        do {
            try FileManager.default.copyItem(at: AppLogger.logFile, to: desktopDirectory.appending(path: "AirMute.log"))
        }
        catch {
            let alert = NSAlert(error: error)
            alert.informativeText = "The log file could not be copied as it does not exist."
            alert.messageText = "Failed to Copy Log File"
            _ = alert.runModal()
        }
    }
}
