import Foundation
import Speech
import AVFoundation
import SwiftUI
import Combine

class AudioManager: NSObject, ObservableObject {
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "zh-CN"))
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    private var silentPlayer: AVAudioPlayer?
    private var backgroundTaskID: UIBackgroundTaskIdentifier = .invalid
    
    @Published var isMonitoring = false
    @Published var lastTranscribedText = ""
    @Published var lastMatchStatus = ""
    @Published var targetStations: Set<Station> = []
    var onMatchFound: ((Station) -> Void)?
    
    private var recognitionTaskTimeoutTimer: Timer?
    
    override init() {
        super.init()
        setupNotifications()
        setupSilentAudio()
        setupAppStateObservers()
    }
    
    private var aliveHeartbeatTimer: Timer?
    
    private func setupAppStateObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(didEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(willEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    
    @objc private func didEnterBackground() {
        print("DEBUG: App entered background")
        if isMonitoring {
            startBackgroundTask()
            silentPlayer?.play()
            startHeartbeat()
        }
    }
    
    @objc private func willEnterForeground() {
        print("DEBUG: App entered foreground")
        endBackgroundTask()
        stopHeartbeat()
    }
    
    private func startHeartbeat() {
        stopHeartbeat()
        aliveHeartbeatTimer = Timer.scheduledTimer(withTimeInterval: 10, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            if UIApplication.shared.applicationState != .active {
                NotificationManager.shared.triggerDebugNotification(text: "💓 Background Alive Heartbeat")
                
                // Update Live Activity to keep it "fresh" in system's eyes
                if let station = self.targetStations.first {
                    NotificationManager.shared.startLiveActivity(for: station.name)
                }
                
                // Safety check: ensure engine is still running
                if !self.audioEngine.isRunning && self.isMonitoring {
                    try? self.audioEngine.start()
                }
            }
        }
    }
    
    private func stopHeartbeat() {
        aliveHeartbeatTimer?.invalidate()
        aliveHeartbeatTimer = nil
    }

    private func startBackgroundTask() {
        endBackgroundTask()
        backgroundTaskID = UIApplication.shared.beginBackgroundTask(withName: "MetroAlertMonitoring") { [weak self] in
            print("DEBUG: Background task expired")
            self?.endBackgroundTask()
            if self?.isMonitoring == true {
                self?.restartRecognition()
            }
        }
    }
    
    private func endBackgroundTask() {
        if backgroundTaskID != .invalid {
            UIApplication.shared.endBackgroundTask(backgroundTaskID)
            backgroundTaskID = .invalid
        }
    }
    
    private func setupSilentAudio() {
        if let url = Bundle.main.url(forResource: "silence", withExtension: "wav") {
            do {
                silentPlayer = try AVAudioPlayer(contentsOf: url)
                silentPlayer?.numberOfLoops = -1
                silentPlayer?.volume = 0.05 // Slightly higher volume for dither noise
                silentPlayer?.prepareToPlay()
            } catch {
                print("DEBUG: Silent player setup error: \(error)")
            }
        }
    }
    
    private func setupNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleInterruption), name: AVAudioSession.interruptionNotification, object: nil)
    }
    
    @objc private func handleInterruption(notification: Notification) {
        guard let userInfo = notification.userInfo,
              let typeValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
              let type = AVAudioSession.InterruptionType(rawValue: typeValue) else { return }
        
        if type == .began {
            print("DEBUG: Audio interruption began")
        } else if type == .ended {
            if let optionsValue = userInfo[AVAudioSessionInterruptionOptionKey] as? UInt {
                let options = AVAudioSession.InterruptionOptions(rawValue: optionsValue)
                if options.contains(.shouldResume) && !targetStations.isEmpty {
                    print("DEBUG: Resuming monitoring after interruption")
                    startRecording()
                }
            }
        }
    }
    
    func addTargetStation(_ station: Station) {
        targetStations.insert(station)
        lastMatchStatus = "正在等待报站..."
        
        if !isMonitoring {
            requestPermissions { [weak self] granted in
                guard granted else { return }
                self?.startRecording()
            }
        }
    }
    
    func removeTargetStation(_ station: Station) {
        targetStations.remove(station)
        if targetStations.isEmpty {
            stopMonitoring()
            lastMatchStatus = ""
        }
    }
    
    func stopMonitoring() {
        print("DEBUG: Stopping monitoring")
        silentPlayer?.stop()
        endBackgroundTask()
        stopHeartbeat()
        recognitionTaskTimeoutTimer?.invalidate()
        recognitionTaskTimeoutTimer = nil
        
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        recognitionRequest?.endAudio()
        recognitionTask?.cancel()
        
        isMonitoring = false
        targetStations.removeAll()
        lastMatchStatus = ""
        lastTranscribedText = ""
    }
    
    private func requestPermissions(completion: @escaping (Bool) -> Void) {
        SFSpeechRecognizer.requestAuthorization { authStatus in
            AVAudioSession.sharedInstance().requestRecordPermission { micGranted in
                DispatchQueue.main.async {
                    completion(authStatus == .authorized && micGranted)
                }
            }
        }
    }
    
    private func startRecording() {
        guard !isMonitoring else { return }
        print("DEBUG: Starting Ground Monitoring. AppState: \(UIApplication.shared.applicationState.rawValue)")
        
        if UIApplication.shared.applicationState != .active && backgroundTaskID == .invalid {
            startBackgroundTask()
            startHeartbeat()
        }
        
        silentPlayer?.play()
        isMonitoring = true

        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.playAndRecord, mode: .measurement, options: [.duckOthers, .defaultToSpeaker, .mixWithOthers, .allowBluetooth, .allowBluetoothA2DP])
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print("DEBUG: Audio session error: \(error)")
        }

        setupAudioEngineAndTap()
        createNewRecognitionTask()
    }
    
    private func setupAudioEngineAndTap() {
        let inputNode = audioEngine.inputNode
        inputNode.removeTap(onBus: 0)
        
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { [weak self] buffer, _ in
            self?.recognitionRequest?.append(buffer)
        }
        
        do {
            audioEngine.prepare()
            try audioEngine.start()
            print("DEBUG: Audio Engine Started")
        } catch {
            print("DEBUG: Engine start fail: \(error)")
            NotificationManager.shared.triggerDebugNotification(text: "⚠️ 引擎启动失败")
        }
    }
    
    private func createNewRecognitionTask() {
        recognitionTask?.cancel()
        recognitionTask = nil
        recognitionRequest?.endAudio()
        recognitionRequest = nil
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            guard let self = self, self.isMonitoring else { return }
            
            self.recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
            guard let request = self.recognitionRequest else { return }
            request.shouldReportPartialResults = true
            request.requiresOnDeviceRecognition = false
            
            self.recognitionTask = self.speechRecognizer?.recognitionTask(with: request) { [weak self] result, error in
                guard let self = self else { return }
                
                if let result = result {
                    let text = result.bestTranscription.formattedString
                    print("DEBUG: Recognized: \(text)")
                    
                    if UIApplication.shared.applicationState != .active {
                        NotificationManager.shared.triggerDebugNotification(text: "识别到：\(text)")
                    }
                    
                    DispatchQueue.main.async {
                        self.lastTranscribedText = text
                        self.checkForMatch(text)
                    }
                }
                
                if let error = error {
                    let nsError = error as NSError
                    if self.isMonitoring && !self.targetStations.isEmpty {
                        if nsError.code != 204 && UIApplication.shared.applicationState != .active {
                            NotificationManager.shared.triggerDebugNotification(text: "❌ 任务重置 [\(nsError.code)]")
                        }
                        
                        if nsError.code != 1110 { 
                            self.restartRecognition()
                        } else {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                                self.restartRecognition()
                            }
                        }
                    }
                }
            }
            
            self.recognitionTaskTimeoutTimer?.invalidate()
            self.recognitionTaskTimeoutTimer = Timer.scheduledTimer(withTimeInterval: 40, repeats: false) { [weak self] _ in
                self?.restartRecognition()
            }
        }
    }
    
    private func restartRecognition() {
        guard isMonitoring && !targetStations.isEmpty else { return }
        print("DEBUG: Graceful Task Handoff")
        
        recognitionRequest?.endAudio()
        recognitionTask?.cancel()
        
        if UIApplication.shared.applicationState != .active {
            NotificationManager.shared.triggerDebugNotification(text: "🔄 切换监听通道...")
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            self?.createNewRecognitionTask()
        }
    }
    
    private func checkForMatch(_ text: String) {
        guard !targetStations.isEmpty else { return }
        
        let keywords = ["下一站", "现在到达", "到达", "即将", "站名", "Next station", "Arriving at"]
        let lowerText = text.lowercased()
        
        for station in targetStations {
            let containsKeyword = keywords.contains { lowerText.contains($0.lowercased()) }
            let containsTargetCn = lowerText.contains(station.name.lowercased())
            let containsTargetEn = lowerText.contains(station.nameEn.lowercased())
            
            let isExactMatch = (lowerText == station.name.lowercased() || lowerText == station.nameEn.lowercased())
            
            if (containsKeyword && (containsTargetCn || containsTargetEn)) || isExactMatch {
                self.lastMatchStatus = "匹配成功: \(station.name)"
                self.onMatchFound?(station)
                self.removeTargetStation(station)
            } else if lowerText.contains(station.name.lowercased()) || lowerText.contains(station.nameEn.lowercased()) {
                self.lastMatchStatus = "检测到站点名，等待关键词..."
            }
        }
    }
}
