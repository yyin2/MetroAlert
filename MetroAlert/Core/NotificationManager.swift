import Foundation
import UserNotifications
import UIKit
import ActivityKit
import AudioToolbox

class NotificationManager: NSObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationManager()
    private var activeActivities: [String: Activity<MetroAlertAttributes>] = [:]
    
    // Track which stations are currently in "alert" mode
    private(set) var alertStations: Set<String> = []
    private var isVibrating = false
    
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
        print("DEBUG: Finalizing alert request for \(stationName)")
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            // 1. Add to active alerts
            self.alertStations.insert(stationName)
            print("DEBUG: Active alert stations: \(self.alertStations)")
            
            // 2. Local Notification
            let content = UNMutableNotificationContent()
            content.title = "🚇 目的地站到了"
            content.body = "已经到达或即将到达：\(stationName)"
            // Use standard sound for better background reliability when miked
            content.sound = .default
            
            // Unique identifier per station to ensure multiple banners show
            let request = UNNotificationRequest(identifier: "arrived_\(stationName)", content: content, trigger: nil)
            UNUserNotificationCenter.current().add(request)
            
            // 3. Start/Maintain vibration
            self.startAlertVibration()
        }
    }
    
    func dismissAlert(for stationName: String) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            print("DEBUG: User dismissed alert for \(stationName)")
            self.alertStations.remove(stationName)
            print("DEBUG: Remaining alert stations: \(self.alertStations)")
            
            // If no more stations are alerting, stop vibration
            if self.alertStations.isEmpty {
                self.stopAlertVibration()
            }
        }
    }
    
    func triggerDebugNotification(text: String) {
        let content = UNMutableNotificationContent()
        content.title = "🔍 监听诊断 (调试用)"
        content.body = text
        content.sound = nil 
        
        let request = UNNotificationRequest(identifier: "debug_transcription", content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request)
    }
    
    private func startAlertVibration() {
        guard !isVibrating else {
            print("DEBUG: Vibration already running for: \(alertStations)")
            return 
        }
        
        print("DEBUG: Starting persistent recursive vibration loop")
        isVibrating = true
        runVibrationLoop()
    }
    
    private func runVibrationLoop() {
        guard isVibrating && !alertStations.isEmpty else {
            print("DEBUG: Vibration loop terminated (isVibrating: \(isVibrating), count: \(alertStations.count))")
            isVibrating = false
            return
        }
        
        // Use AlertSound which is higher priority than SystemSound
        AudioServicesPlayAlertSound(kSystemSoundID_Vibrate)
        
        // Recursive call for better background stability than a Timer
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) { [weak self] in
            self?.runVibrationLoop()
        }
    }
    
    func stopAlertVibration() {
        print("DEBUG: Signaling vibration loop to stop")
        isVibrating = false
    }
    
    // Stop ALL alerts (e.g. when app stops monitoring)
    func clearAllAlerts() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            print("DEBUG: Force clearing all active alerts")
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
