import Foundation
import UserNotifications
import UIKit
import ActivityKit

class NotificationManager: NSObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationManager()
    private var activeActivities: [String: Activity<MetroAlertAttributes>] = [:]
    
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
        print("DEBUG: Triggering notification for \(stationName)")
        
        // 1. Local Notification
        let content = UNMutableNotificationContent()
        content.title = "🚇 目的地站到了"
        content.body = "已经到达或即将到达：\(stationName)"
        content.sound = .default // Use standard sound for maximum compatibility
        
        // Unique identifier to ensure multiple notifications can show
        let request = UNNotificationRequest(identifier: "arrived_\(stationName)_\(Date().timeIntervalSince1970)", content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("DEBUG: Error adding notification: \(error)")
            } else {
                print("DEBUG: Notification added successfully")
            }
        }
        
        // 2. Haptic Feedback (Vibration)
        triggerHeavyVibration()
    }
    
    func triggerDebugNotification(text: String) {
        let content = UNMutableNotificationContent()
        content.title = "🔍 监听诊断 (调试用)"
        content.body = text
        content.sound = nil // Silent for diagnosis
        
        let request = UNNotificationRequest(identifier: "debug_transcription", content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request)
    }
    
    private func triggerHeavyVibration() {
        print("DEBUG: Starting haptic feedback")
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(.success)
        
        // Additional heavy impacts for better feel
        for i in 0..<4 {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.4) {
                let impact = UIImpactFeedbackGenerator(style: .heavy)
                impact.prepare()
                impact.impactOccurred()
                print("DEBUG: Haptic impact iteration \(i)")
            }
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
