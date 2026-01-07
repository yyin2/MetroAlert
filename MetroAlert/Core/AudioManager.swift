import Foundation
import Speech
import AVFoundation
import SwiftUI
import Combine

class AudioManager: ObservableObject {
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "zh-CN"))
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    
    @Published var isMonitoring = false
    @Published var lastTranscribedText = ""
    
    var targetStation: Station?
    var onMatchFound: (() -> Void)?
    
    func startMonitoring(for station: Station) {
        self.targetStation = station
        requestPermissions { [weak self] granted in
            guard granted else { return }
            self?.startRecording()
        }
    }
    
    func stopMonitoring() {
        audioEngine.stop()
        recognitionRequest?.endAudio()
        isMonitoring = false
    }
    
    private func requestPermissions(completion: @escaping (Bool) -> Void) {
        SFSpeechRecognizer.requestAuthorization { authStatus in
            DispatchQueue.main.async {
                completion(authStatus == .authorized)
            }
        }
    }
    
    private func startRecording() {
        if recognitionTask != nil {
            recognitionTask?.cancel()
            recognitionTask = nil
        }
        
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print("Audio session error: \(error)")
        }
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        
        guard let recognitionRequest = recognitionRequest else { return }
        recognitionRequest.shouldReportPartialResults = true
        
        // Use on-device recognition if available for battery/privacy
        if #available(iOS 13, *), speechRecognizer?.supportsOnDeviceRecognition == true {
            recognitionRequest.requiresOnDeviceRecognition = true
        }
        
        let inputNode = audioEngine.inputNode
        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest) { [weak self] result, error in
            guard let self = self else { return }
            
            if let result = result {
                let text = result.bestTranscription.formattedString
                self.lastTranscribedText = text
                self.checkForMatch(text)
            }
            
            if error != nil || result?.isFinal == true {
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                self.recognitionRequest = nil
                self.recognitionTask = nil
                self.isMonitoring = false
            }
        }
        
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            self.recognitionRequest?.append(buffer)
        }
        
        audioEngine.prepare()
        do {
            try audioEngine.start()
            isMonitoring = true
        } catch {
            print("Audio Engine start error: \(error)")
        }
    }
    
    private func checkForMatch(_ text: String) {
        guard let target = targetStation?.name else { return }
        
        let keywords = ["下一站", "到达", "Next station", "Arriving at"]
        let lowerText = text.lowercased()
        let lowerTarget = target.lowercased()
        
        // Check if both keywords and target station are in the transcribed text
        let containsKeyword = keywords.contains { lowerText.contains($0.lowercased()) }
        let containsTarget = lowerText.contains(lowerTarget)
        
        if containsKeyword && containsTarget {
            DispatchQueue.main.async {
                self.onMatchFound?()
                self.stopMonitoring()
            }
        }
    }
}
