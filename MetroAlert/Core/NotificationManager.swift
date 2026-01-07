import Foundation
import UserNotifications
import UIKit
import ActivityKit

class NotificationManager {
    static let shared = NotificationManager()
    private var currentActivity: Activity<MetroAlertAttributes>?
    
    func requestPermissions() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("Notification permission granted")
            }
        }
    }
    
    func triggerArrivedNotification(stationName: String) {
        // 1. Local Notification
        let content = UNMutableNotificationContent()
        content.title = "地铁到站提醒"
        content.body = "您即将到达：\(stationName)"
        content.sound = .defaultCritical // Use critical sound if possible
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request)
        
        // 2. Haptic Feedback (Vibration)
        triggerHeavyVibration()
    }
    
    private func triggerHeavyVibration() {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(.success)
        
        // Repeat vibration for emphasis
        for i in 0..<5 {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.5) {
                let impact = UIImpactFeedbackGenerator(style: .heavy)
                impact.impactOccurred()
            }
        }
    }
    
    // MARK: - Live Activity
    
    func startLiveActivity(for stationName: String) {
        if #available(iOS 16.1, *) {
            let attributes = MetroAlertAttributes(targetStation: stationName)
            let initialState = MetroAlertAttributes.ContentState(stationName: stationName, status: "Listening...")
            
            do {
                currentActivity = try Activity.request(attributes: attributes, contentState: initialState)
            } catch {
                print("Error starting Live Activity: \(error.localizedDescription)")
            }
        }
    }
    
    func stopLiveActivity() {
        if #available(iOS 16.1, *) {
            Task {
                await currentActivity?.end(dismissalPolicy: .immediate)
                currentActivity = nil
            }
        }
    }
}
