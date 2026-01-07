import AudioToolbox

class NotificationManager: NSObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationManager()
    private var activeActivities: [String: Activity<MetroAlertAttributes>] = [:]
    private var vibrationTimer: Timer?
    private var vibrationStartTime: Date?
    
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
        content.sound = UNNotificationSound.defaultCriticalSound(withAudioVolume: 1.0)
        
        // Unique identifier to ensure multiple notifications can show
        let request = UNNotificationRequest(identifier: "arrived_\(stationName)_\(Date().timeIntervalSince1970)", content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("DEBUG: Error adding notification: \(error)")
            }
        }
        
        // 2. Persistent 1-minute vibration
        startAlertVibration()
    }
    
    func triggerDebugNotification(text: String) {
        let content = UNMutableNotificationContent()
        content.title = "🔍 监听诊断 (调试用)"
        content.body = text
        content.sound = nil // Silent for diagnosis
        
        let request = UNNotificationRequest(identifier: "debug_transcription", content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request)
    }
    
    private func startAlertVibration() {
        stopAlertVibration() // Reset if any existing
        
        print("DEBUG: Starting persistent 1-minute vibration")
        vibrationStartTime = Date()
        
        // Standard vibration is ~0.4s. We vibrate every 1.0s to give the user a clear rhythmic alert.
        vibrationTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self, let start = self.vibrationStartTime else { return }
            
            // Limit to 60 seconds
            if Date().timeIntervalSince(start) > 60 {
                self.stopAlertVibration()
                return
            }
            
            // primitive vibration works better in background than Taptic Engine generators
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
        }
        
        // Initial vibration immediately
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
    }
    
    func stopAlertVibration() {
        print("DEBUG: Stopping alert vibration")
        vibrationTimer?.invalidate()
        vibrationTimer = nil
        vibrationStartTime = nil
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
