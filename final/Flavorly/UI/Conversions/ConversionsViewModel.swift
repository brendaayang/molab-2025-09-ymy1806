//
//  ConversionsViewModel.swift
//  Flavorly
//
//  Created by Brenda Yang on 9/19/25.
//

import SwiftUI
import Speech
import AVFoundation

final class ConversionsViewModel: Bindable, ViewModel {
    let id = UUID()
    
    private let conversionService: ConversionServiceProtocol
    private let timerService: TimerServiceProtocol
    private let speechRecognizer = SFSpeechRecognizer()
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    
    @Published var queryText = ""
    @Published var result: ConversionResult?
    @Published var isListening = false
    @Published var errorMessage: String?
    @Published var permissionStatus: SFSpeechRecognizerAuthorizationStatus = .notDetermined
    
    // Timer properties
    @Published var activeTimers: [BakingTimer] = []
    @Published var showingAddTimer = false
    
    init(conversionService: ConversionServiceProtocol, timerService: TimerServiceProtocol) {
        self.conversionService = conversionService
        self.timerService = timerService
        super.init()
        bind()
        checkPermissions()
        
        // Subscribe to timer updates
        timerService.activeTimers
            .assign(to: &$activeTimers)
    }
    
    func checkPermissions() {
        SFSpeechRecognizer.requestAuthorization { [weak self] status in
            DispatchQueue.main.async {
                self?.permissionStatus = status
            }
        }
    }
    
    func convert() {
        guard !queryText.isEmpty else {
            errorMessage = "say something first!"
            return
        }
        
        if let result = conversionService.parseQuery(queryText) {
            self.result = result
            errorMessage = nil
        } else {
            errorMessage = "couldn't understand that, try something like '30 grams to cups'"
        }
    }
    
    func startListening() {
        guard permissionStatus == .authorized else {
            errorMessage = "Please enable microphone permissions in Settings"
            return
        }
        
        if audioEngine.isRunning {
            stopListening()
            return
        }
        
        do {
            try startRecording()
            isListening = true
        } catch {
            errorMessage = "Could not start recording: \(error.localizedDescription)"
        }
    }
    
    func stopListening() {
        audioEngine.stop()
        recognitionRequest?.endAudio()
        isListening = false
    }
    
    private func startRecording() throws {
        // Cancel previous task
        recognitionTask?.cancel()
        recognitionTask = nil
        
        // Configure audio session
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        
        let inputNode = audioEngine.inputNode
        
        guard let recognitionRequest = recognitionRequest else {
            throw NSError(domain: "ConversionError", code: 1, userInfo: nil)
        }
        
        recognitionRequest.shouldReportPartialResults = true
        
        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest) { [weak self] result, error in
            guard let self = self else { return }
            
            if let result = result {
                DispatchQueue.main.async {
                    self.queryText = result.bestTranscription.formattedString
                }
            }
            
            if error != nil || result?.isFinal == true {
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                self.recognitionRequest = nil
                self.recognitionTask = nil
                DispatchQueue.main.async {
                    self.isListening = false
                    if !self.queryText.isEmpty {
                        self.convert()
                    }
                }
            }
        }
        
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            recognitionRequest.append(buffer)
        }
        
        audioEngine.prepare()
        try audioEngine.start()
    }
    
    // MARK: - Timer Methods
    
    func addTimer(name: String, duration: TimeInterval, color: TimerColor) {
        let timer = BakingTimer(name: name, duration: duration, color: color)
        timerService.addTimer(timer)
    }
    
    func removeTimer(id: UUID) {
        timerService.removeTimer(id: id)
    }
    
    func pauseTimer(id: UUID) {
        timerService.pauseTimer(id: id)
    }
    
    func resumeTimer(id: UUID) {
        timerService.resumeTimer(id: id)
    }
}

