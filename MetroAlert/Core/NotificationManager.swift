import Foundation
import UserNotifications
import UIKit
import ActivityKit
import AudioToolbox
import Combine

class NotificationManager: NSObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationManager()
    private var activeActivities: [String: Activity<MetroAlertAttributes>] = [:]
    
    // Track which stations are currently in "alert" mode
    private(set) var alertStations: Set<String> = []
    @Published private(set) var isVibrating = false
    
    var hasActiveAlerts: Bool {
        return !alertStations.isEmpty
    }
    
    override init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
    }
    
    func requestPermissions() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge, .criticalAlert]) { granted, error in
            if granted {
                print("DEBUG: Notification permission granted")
            } else if let error = error {
                print("DEBUG: Notification permission error: \(error)")
            }
        }
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // Show banner and play sound even in foreground
        completionHandler([.banner, .list, .sound])
    }
    
    func triggerArrivedNotification(stationName: String) {
        print("DEBUG: Notification Manager - Triggering for \(stationName)")
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            self.alertStations.insert(stationName)
            
            // Local Notification
            let content = UNMutableNotificationContent()
            content.title = "🚇 目的地已到：\(stationName)"
            content.body = "请准备下车或换乘。"
            content.sound = .default
            
            // Use unique identifier with timestamp to prevent overwriting
            let request = UNNotificationRequest(
                identifier: "arrived_\(stationName)_\(Date().timeIntervalSince1970)", 
                content: content, 
                trigger: nil
            )
            UNUserNotificationCenter.current().add(request)
            
            self.startAlertVibration()
        }
    }
    
    func dismissAlert(for stationName: String) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            print("DEBUG: Dismissing alert station: \(stationName)")
            self.alertStations.remove(stationName)
            
            if self.alertStations.isEmpty {
                self.stopAlertVibration()
            }
        }
    }
    
    func triggerDebugNotification(text: String) {
        let content = UNMutableNotificationContent()
        content.title = "🔍 监听诊断"
        content.body = text
        content.sound = nil 
        
        let request = UNNotificationRequest(identifier: "debug_transcription", content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request)
    }
    
    private func startAlertVibration() {
        guard !isVibrating else {
            print("DEBUG: Vibration already active. Stations: \(alertStations)")
            return 
        }
        
        print("DEBUG: Spawning dedicated vibration thread")
        isVibrating = true
        
        // Detach a new thread to ensure the loop runs independently of the Main runloop
        // This is the most reliable way to maintain a pulse in the background
        Thread.detachNewThread { [weak self] in
            print("DEBUG: Vibration thread started")
            while true {
                guard let self = self, self.isVibrating, !self.alertStations.isEmpty else {
                    print("DEBUG: Vibration thread condition failed, exiting...")
                    self?.stopVibrationFlag()
                    break
                }
                
                // standard system vibration
                AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
                
                // Pulse every 1.1s to allow the 0.4s vibration to finish and breath
                Thread.sleep(forTimeInterval: 1.1)
            }
        }
    }
    
    private func stopVibrationFlag() {
        DispatchQueue.main.async {
            self.isVibrating = false
        }
    }
    
    func stopAlertVibration() {
        print("DEBUG: Requesting vibration stop")
        isVibrating = false
    }
    
    func clearAllAlerts() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            print("DEBUG: Force clearing all alerts")
            self.alertStations.removeAll()
            self.stopAlertVibration()
        }
    }
    
    // MARK: - Live Activity
    
    func startLiveActivity(for stationName: String) {
        // Avoid duplicate activities for the same station
        guard activeActivities[stationName] == nil else { return }
        
        if #available(iOS 16.1, *) {
            let attributes = MetroAlertAttributes(targetStation: stationName)
            let initialState = MetroAlertAttributes.ContentState(stationName: stationName, status: "Listening...")
            
            do {
                let activity = try Activity.request(attributes: attributes, contentState: initialState)
                activeActivities[stationName] = activity
            } catch {
                print("Error starting Live Activity: \(error.localizedDescription)")
            }
        }
    }
    
    func stopLiveActivity(for stationName: String) {
        if #available(iOS 16.1, *) {
            Task {
                await activeActivities[stationName]?.end(dismissalPolicy: .immediate)
                activeActivities.removeValue(forKey: stationName)
            }
        }
    }
    
    func stopAllActivities() {
        if #available(iOS 16.1, *) {
            Task {
                for activity in activeActivities.values {
                    await activity.end(dismissalPolicy: .immediate)
                }
                activeActivities.removeAll()
            }
        }
    }
}
