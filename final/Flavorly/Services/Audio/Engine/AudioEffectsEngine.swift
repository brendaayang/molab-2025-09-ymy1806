import Foundation
import AVFoundation
import Combine

final class AudioEffectsEngine: ObservableObject {
    private let engine = AVAudioEngine()
    private let player = AVAudioPlayerNode()
    private let pitchEffect = AVAudioUnitTimePitch()
    private let reverb = AVAudioUnitReverb()
    
    // Expose engine for audio analysis
    var audioEngine: AVAudioEngine {
        return engine
    }
    
    @Published var isPlaying = false
    @Published var currentTime: TimeInterval = 0
    @Published var duration: TimeInterval = 0
    @Published var currentEffect: AudioEffect = .normal
    
    private var audioFile: AVAudioFile?
    private var timer: Timer?
    
    init() {
        setupAudioEngine()
        configureAudioSession()
    }
    
    private func setupAudioEngine() {
        // Attach nodes
        engine.attach(player)
        engine.attach(pitchEffect)
        engine.attach(reverb)
        
        // Connect nodes: player -> pitch -> reverb -> output
        engine.connect(player, to: pitchEffect, format: nil)
        engine.connect(pitchEffect, to: reverb, format: nil)
        engine.connect(reverb, to: engine.mainMixerNode, format: nil)
        
        // Default reverb settings (will be adjusted per effect)
        reverb.loadFactoryPreset(.largeHall)
        reverb.wetDryMix = 0 // Start with no reverb
        
        // Prepare and start engine
        engine.prepare()
        try? engine.start()
    }
    
    private func configureAudioSession() {
        // Configure for pristine audio quality
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.playback, mode: .moviePlayback, options: [])
            try audioSession.setActive(true)
            // Request high sample rate for best quality
            try audioSession.setPreferredSampleRate(44100)
        } catch {
            print("❌ Failed to configure audio session: \(error)")
        }
    }
    
    func loadAudio(from url: URL) {
        print("🎵 AudioEngine: Loading audio from: \(url)")
        print("🎵 AudioEngine: File extension: \(url.pathExtension)")
        
        do {
            audioFile = try AVAudioFile(forReading: url)
            if let file = audioFile {
                duration = Double(file.length) / file.processingFormat.sampleRate
                print("✅ AudioEngine: Audio loaded successfully. Duration: \(duration)s")
            }
            currentTime = 0
        } catch {
            print("❌ AudioEngine: Failed to load audio file: \(error)")
            print("❌ AudioEngine: Error details: \(error.localizedDescription)")
        }
    }
    
    func play() {
        guard let file = audioFile else {
            print("❌ AudioEngine: No audio file loaded, cannot play")
            return
        }
        
        print("▶️ AudioEngine: Starting playback...")
        
        if !engine.isRunning {
            try? engine.start()
        }
        
        player.stop()
        
        // Schedule the file
        player.scheduleFile(file, at: nil) { [weak self] in
            DispatchQueue.main.async {
                self?.isPlaying = false
                self?.currentTime = 0
                self?.stopTimer()
            }
        }
        
        player.play()
        isPlaying = true
        startTimer()
    }
    
    func pause() {
        player.pause()
        isPlaying = false
        stopTimer()
    }
    
    func stop() {
        player.stop()
        isPlaying = false
        currentTime = 0
        stopTimer()
    }
    
    func seek(to time: TimeInterval) {
        guard let file = audioFile else { return }
        
        let wasPlaying = isPlaying
        player.stop()
        
        let sampleRate = file.processingFormat.sampleRate
        let startFrame = AVAudioFramePosition(time * sampleRate)
        
        guard startFrame < file.length else { return }
        
        let frameCount = AVAudioFrameCount(file.length - startFrame)
        
        player.scheduleSegment(file, startingFrame: startFrame, frameCount: frameCount, at: nil) { [weak self] in
            DispatchQueue.main.async {
                self?.isPlaying = false
                self?.stopTimer()
            }
        }
        
        currentTime = time
        
        if wasPlaying {
            player.play()
            isPlaying = true
            startTimer()
        }
    }
    
    func applyEffect(_ effect: AudioEffect) {
        currentEffect = effect
        
        switch effect {
        case .normal:
            applyNormal()
        case .slowedReverb:
            applySlowedReverb()
        case .nightcore:
            applyNightcore()
        }
    }
    
    private func applyNormal() {
        pitchEffect.pitch = 0
        pitchEffect.rate = 1.0
        reverb.wetDryMix = 0
    }
    
    private func applySlowedReverb() {
        pitchEffect.pitch = -200 // Lower pitch slightly
        pitchEffect.rate = 0.75 // 75% speed (slowed)
        pitchEffect.overlap = 8 // Higher quality time stretching
        reverb.loadFactoryPreset(.cathedral) // More dramatic reverb
        reverb.wetDryMix = 50 // 50% reverb mix
    }
    
    private func applyNightcore() {
        pitchEffect.pitch = 400 // +400 cents (higher pitch)
        pitchEffect.rate = 1.15 // 115% speed (faster)
        pitchEffect.overlap = 8 // Higher quality time stretching
        reverb.wetDryMix = 0 // No reverb
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self = self, self.isPlaying else { return }
            
            if let nodeTime = self.player.lastRenderTime,
               let playerTime = self.player.playerTime(forNodeTime: nodeTime) {
                let seconds = Double(playerTime.sampleTime) / playerTime.sampleRate
                self.currentTime = seconds / Double(self.pitchEffect.rate)
            }
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    deinit {
        stop()
        engine.stop()
    }
}

