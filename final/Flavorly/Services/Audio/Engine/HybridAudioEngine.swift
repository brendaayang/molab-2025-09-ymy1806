//
//  HybridAudioEngine.swift
//  Flavorly
//
//  Created by Brenda Yang on 10/19/25.
//

import Foundation
import AVFoundation
import Combine

/// Handles both audio files (mp3) and video files (mp4) with audio effects
final class HybridAudioEngine: ObservableObject {
    // Audio effects engine for mp3 files
    let audioEffectsEngine = AudioEffectsEngine()
    
    // Video player for mp4 files
    var videoPlayer: AVPlayer?
    var currentMediaType: MediaType = .audio
    var currentMediaURL: URL?  // Track currently loaded media to prevent duplicate loads
    
    // Telemetry throttling
    private var lastTelemetryTime: Date = Date()
    private var eventCount: Int = 0
    
    // Continuous decay timer
    private var decayTimer: Timer?
    
    // Beat-synced player for look-ahead analysis
    private var beatSyncedPlayer: BeatSyncedPlayer?
    @Published var currentBeatEvent: BeatEvent?
    @Published var musicControls = MusicControls()
    
    // Vibe detection system
    private let vibeEstimator = VibeEstimator()
    
    @Published var isPlaying = false
    @Published var currentTime: TimeInterval = 0
    @Published var duration: TimeInterval = 0
    @Published var currentEffect: AudioEffect = .normal
    
    private var timer: Timer?
    
    enum MediaType {
        case audio
        case video
    }
    
    init() {
        // Observe audioEffectsEngine
        audioEffectsEngine.$isPlaying.assign(to: &$isPlaying)
        audioEffectsEngine.$currentTime.assign(to: &$currentTime)
        audioEffectsEngine.$duration.assign(to: &$duration)
        audioEffectsEngine.$currentEffect.assign(to: &$currentEffect)
        print("🎵 HybridAudioEngine: Initialized")
    }
    
    deinit {
        print("🗑️ HybridAudioEngine: Deinit called - cleaning up")
        stop()
        NotificationCenter.default.removeObserver(self)
        timer?.invalidate()
        stopVideoTimer()
    }
    
    func loadMedia(from url: URL) {
        print("🎵 HybridEngine: Loading media from: \(url)")
        
        // Stop any ongoing analysis immediately
        print("🛑 HybridEngine: Stopping ongoing analysis before loading new media")
        beatSyncedPlayer?.stop()
        beatSyncedPlayer = nil
        
        // Reset music controls to prevent pink bars
        musicControls.reset()
        
        // Initialize vibe estimator for new track
        let assetKey = url.lastPathComponent
        vibeEstimator.start(assetKey: assetKey, startTime: 0)
        
        // CRITICAL: Check if this same media is already loaded - if so, don't reload
        if let currentURL = currentMediaURL, currentURL == url {
            print("⏭ HybridEngine: Media already loaded, skipping reload to prevent duplicate playback")
            return
        }
        
        let ext = url.pathExtension.lowercased()
        
        // EDGE CASE: Clean up old video player before loading new media (prevent memory leaks)
        if let oldPlayer = videoPlayer {
            print("🧹 HybridEngine: Cleaning up old video player")
            oldPlayer.pause()
            oldPlayer.replaceCurrentItem(with: nil)
            NotificationCenter.default.removeObserver(self)
            videoPlayer = nil
        }
        
        // Store current media URL
        currentMediaURL = url
        
        // Stop previous beat player
        beatSyncedPlayer?.stop()
        
        if ext == "mp3" {
            // Use audio effects engine for mp3
            currentMediaType = .audio
            audioEffectsEngine.loadAudio(from: url)
            // Setup beat player for MP3
            setupBeatPlayer(for: url)
        } else if ext == "mp4" {
            // Use AVPlayer for video (audio track)
            currentMediaType = .video
            loadVideoAudio(from: url)
            // Setup beat player for MP4
            setupBeatPlayer(for: url)
        }
    }
    
    private func loadVideoAudio(from url: URL) {
        print("🎬 HybridEngine: Loading video audio from mp4")
        
        let asset = AVAsset(url: url)
        let playerItem = AVPlayerItem(asset: asset)
        videoPlayer = AVPlayer(playerItem: playerItem)
        
        // Get duration
        Task {
            do {
                let assetDuration = try await asset.load(.duration)
                await MainActor.run {
                    self.duration = CMTimeGetSeconds(assetDuration)
                    print("✅ HybridEngine: Video audio loaded. Duration: \(self.duration)s")
                }
            } catch {
                print("❌ HybridEngine: Failed to load duration: \(error)")
            }
        }
        
        currentTime = 0
    }
    
    func play() {
        print("▶️ HybridEngine: Play requested (type: \(currentMediaType))")
        print("📊 HybridEngine: Current state - isPlaying: \(isPlaying), currentTime: \(currentTime), duration: \(duration)")
        
        switch currentMediaType {
        case .audio:
            print("🎵 HybridEngine: Playing audio file via AudioEffectsEngine")
            audioEffectsEngine.play()
            print("🎵 HybridEngine: AudioEffectsEngine state - isPlaying: \(audioEffectsEngine.isPlaying)")
        case .video:
            print("🎥 HybridEngine: Playing video file via AVPlayer")
            videoPlayer?.play()
            isPlaying = true
            startVideoTimer()
            print("🎥 HybridEngine: AVPlayer rate: \(videoPlayer?.rate ?? 0)")
            
            // Start time observer for beat sync
            if let player = videoPlayer {
                beatSyncedPlayer?.startTimeObserver(player: player)
            }
        }
        
        print("✅ HybridEngine: Play complete - isPlaying: \(isPlaying)")
    }
    
    func pause() {
        print("⏸ HybridEngine: Pause requested (type: \(currentMediaType))")
        
        switch currentMediaType {
        case .audio:
            print("🎵 HybridEngine: Pausing audio via AudioEffectsEngine")
            audioEffectsEngine.pause()
        case .video:
            print("🎥 HybridEngine: Pausing video via AVPlayer")
            videoPlayer?.pause()
            isPlaying = false
            stopVideoTimer()
            // Stop time observer for beat sync
            if let player = videoPlayer {
                beatSyncedPlayer?.stopTimeObserver(player: player)
            }
        }
        
        print("✅ HybridEngine: Pause complete - isPlaying: \(isPlaying)")
    }
    
    func stop() {
        print("⏹ HybridEngine: Stop requested (type: \(currentMediaType))")
        
        // Clear currently loaded media URL so next load will work
        currentMediaURL = nil
        print("🧹 HybridEngine: Cleared currentMediaURL")
        
        // Stop beat player
        beatSyncedPlayer?.stop()
        print("🧹 HybridEngine: Stopped BeatSyncedPlayer")
        
        // Stop decay timer
        stopDecayTimer()
        
        switch currentMediaType {
        case .audio:
            print("🎵 HybridEngine: Stopping audio")
            audioEffectsEngine.stop()
        case .video:
            print("🎥 HybridEngine: Stopping video")
            videoPlayer?.pause()
            videoPlayer?.seek(to: .zero)
            isPlaying = false
            currentTime = 0
            stopVideoTimer()
        }
        
        print("✅ HybridEngine: Stop complete")
    }
    
    func seek(to time: TimeInterval) {
        switch currentMediaType {
        case .audio:
            audioEffectsEngine.seek(to: time)
        case .video:
            let cmTime = CMTime(seconds: time, preferredTimescale: 600)
            videoPlayer?.seek(to: cmTime)
            currentTime = time
        }
        
        // Notify beat player of seek
        beatSyncedPlayer?.onSeek()
    }
    
    func applyEffect(_ effect: AudioEffect) {
        currentEffect = effect
        
        switch currentMediaType {
        case .audio:
            audioEffectsEngine.applyEffect(effect)
        case .video:
            // Effects don't apply to video playback
            // Could implement using AVAudioEngine if needed
            print("⚠️ HybridEngine: Audio effects not available for video files")
        }
    }
    
    private func startVideoTimer() {
        stopVideoTimer()
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self = self, let player = self.videoPlayer else { return }
            
            let time = CMTimeGetSeconds(player.currentTime())
            self.currentTime = time
            
            // Check if reached end
            if time >= self.duration - 0.1 {
                self.isPlaying = false
                self.stopVideoTimer()
            }
        }
    }
    
    private func stopVideoTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    private func setupBeatPlayer(for url: URL) {
        // CANCEL OLD ANALYSIS FIRST
        print("🛑 HybridEngine: Cancelling old analysis before starting new")
        beatSyncedPlayer?.stop()
        beatSyncedPlayer = nil
        
        let asset = AVAsset(url: url)
        
        let playhead: () -> Double = { [weak self] in
            guard let self = self else { return 0 }
            switch self.currentMediaType {
            case .audio:
                return self.audioEffectsEngine.currentTime
            case .video:
                return self.videoPlayer?.currentTime().seconds ?? 0
            }
        }
        
        beatSyncedPlayer = BeatSyncedPlayer(
            asset: asset,
            playhead: playhead,
            bpmProvider: { [weak self] in
                let bpm = Double(self?.musicControls.currentBPM ?? 120)
                let conf = Double(self?.musicControls.bpmConfidence ?? 0)
                return (bpm, conf)
            }
        )
        beatSyncedPlayer?.start { [weak self] event in
            DispatchQueue.main.async {
                self?.currentBeatEvent = event
                self?.processBeatEvent(event)
                // Individual event logging removed - too spammy
            }
        }
        
        print("✅ HybridEngine: BeatSyncedPlayer setup complete")
    }
    
    private func processBeatEvent(_ event: BeatEvent) {
        // Reset transient flags
        musicControls.didOnset = false
        musicControls.didDrop = false
        musicControls.didSectionBoundary = false
        musicControls.didBrightnessSpike = false
        
        // Low-pass filter BPM from event metadata
        if let bpm = event.metadata?["bpm"] as? Float, bpm > 0 {
            musicControls.currentBPM += (bpm - musicControls.currentBPM) * 0.2
        }
        
        // Update vibe estimation with current event data
        if let vibeScores = event.metadata?["vibeScores"] as? VibeScores {
            let beatsElapsed = musicControls.currentBPM > 0 ? (event.t * Double(musicControls.currentBPM)) / 60.0 : 0
            vibeEstimator.update(currentTime: event.t, beatsElapsed: beatsElapsed, scores: vibeScores)
            
            // Update music controls with vibe state
            musicControls.currentVibe = vibeEstimator.displayMode
            musicControls.vibePhase = vibeEstimator.phase
            if let currentMode = vibeEstimator.currentMode {
                musicControls.vibeConfidence = 0.8  // TODO: Get actual confidence from estimator
            }
        }
        
        // Throttled logging (every 3 seconds)
        eventCount += 1
        let now = Date()
        if now.timeIntervalSince(lastTelemetryTime) >= 3.0 {
            let vibe = musicControls.currentVibe.displayName
            let vibeConf = musicControls.vibeConfidence
            
            print("🎵 ENGINE: \(eventCount) events/3s │ BPM=\(Int(musicControls.currentBPM)) │ bass=\(String(format: "%.2f", musicControls.bassLevel)) │ \(vibe) (\(String(format: "%.0f", vibeConf*100))%)")
            
            lastTelemetryTime = now
            eventCount = 0
        }
        
        // Debug logging for event processing
        if event.kind == .bass {
            print("🔊 BASS EVENT: t=\(String(format: "%.3f", event.t)) strength=\(String(format: "%.3f", event.strength))")
        }
        if event.kind == .brightnessSpike {
            print("✨ BRIGHTNESS EVENT: t=\(String(format: "%.3f", event.t)) strength=\(String(format: "%.3f", event.strength))")
        }
        
        switch event.kind {
        case .bass:
            // Soft-knee compression
            let compressed = pow(max(event.strength, 0), 0.6)
            
            // Peak-hold envelope with exponential decay - more reactive to bass hits
            let oldBassLevel = musicControls.bassLevel
            musicControls.bassLevel = min(1.0, max(musicControls.bassLevel, compressed * 0.8))
            
            // Extract real frequency bands from event metadata - NO PEAK-HOLD, just set them!
            if let freqBands = event.metadata?["frequencyBands"] as? [String: Float] {
                // Light boost, NO caps - let them move freely!
                let scale: Float = 1.3
                
                // DIRECT SET - no peak-hold that causes them to stick at 0.95!
                musicControls.midLevel[0] = (freqBands["mid1"] ?? 0) * scale
                musicControls.midLevel[1] = (freqBands["mid2"] ?? 0) * scale
                musicControls.midLevel[2] = (freqBands["mid3"] ?? 0) * scale
                
                musicControls.highLevel[0] = (freqBands["high1"] ?? 0) * scale
                musicControls.highLevel[1] = (freqBands["high2"] ?? 0) * scale
                musicControls.highLevel[2] = (freqBands["high3"] ?? 0) * scale
            }
            
            // Debug logging for bass events with frequency bands
            if musicControls.bassLevel != oldBassLevel {
                print("🔊 BASS: strength=\(String(format: "%.3f", event.strength)) compressed=\(String(format: "%.3f", compressed)) old=\(String(format: "%.3f", oldBassLevel)) new=\(String(format: "%.3f", musicControls.bassLevel))")
                print("   📊 BANDS: mid=[\(musicControls.midLevel.map { String(format: "%.2f", $0) }.joined(separator: ","))] high=[\(musicControls.highLevel.map { String(format: "%.2f", $0) }.joined(separator: ","))]")
            }
            
        case .onset:
            musicControls.didOnset = true
            
        case .vocalIn:
            // Increase vocal presence with attack
            musicControls.vocalPresence = min(1.0, musicControls.vocalPresence + 0.3)
            
        case .drop:
            musicControls.didDrop = true
            // Side-chain boost then damp
            musicControls.bassLevel = min(1.0, musicControls.bassLevel + 0.25)
            
        case .chorusStart:
            // Hysteresis: require 1 beat off before re-entering
            let now = Date().timeIntervalSince1970
            let beatDuration = 60.0 / Double(musicControls.currentBPM.clamped(min: 40, max: 240))
            
            if !musicControls.isChorus && (now - musicControls.chorusOffTime) > beatDuration {
                musicControls.isChorus = true
                musicControls.chorusHoldTime = now
            }
            
        case .chorusEnd:
            // Hysteresis: require 1 beat on before exiting
            let now = Date().timeIntervalSince1970
            let beatDuration = 60.0 / Double(musicControls.currentBPM.clamped(min: 40, max: 240))
            
            if musicControls.isChorus && (now - musicControls.chorusHoldTime) > beatDuration {
                musicControls.isChorus = false
                musicControls.chorusOffTime = now
            }
            
        case .sectionBoundary:
            musicControls.didSectionBoundary = true
            
        case .vocalPhrase:
            musicControls.vocalPresence = min(1.0, musicControls.vocalPresence + event.strength * 0.1)
            
        case .buildUp:
            musicControls.isBuildUp = true
            
        case .breakdown:
            musicControls.bassLevel *= 0.3  // Reduce bass
            
        case .brightnessSpike:
            musicControls.didBrightnessSpike = true
            let oldBrightness = musicControls.brightness
            musicControls.brightness = min(1.0, musicControls.brightness + event.strength * 0.4)
            if musicControls.brightness != oldBrightness {
                print("✨ BRIGHTNESS: strength=\(String(format: "%.3f", event.strength)) old=\(String(format: "%.3f", oldBrightness)) new=\(String(format: "%.3f", musicControls.brightness))")
            }
            
        case .sustain:
            // Gentle breathing - handled in visuals
            break
        }
        
        // Start continuous decay timer if not already running
        if decayTimer == nil {
            startDecayTimer()
        }
    }
    
    private func startDecayTimer() {
        decayTimer = Timer.scheduledTimer(withTimeInterval: 0.016, repeats: true) { _ in
            self.decayContinuousParameters()
        }
    }
    
    private func stopDecayTimer() {
        decayTimer?.invalidate()
        decayTimer = nil
    }
    
    private func decayContinuousParameters() {
        // Slower decay for smoother transitions
        let decayRate: Float = 0.985 // Slower decay (was 0.865)
        
        // Smooth exponential decay
        if musicControls.bassLevel > 0.01 {
            musicControls.bassLevel *= decayRate
        } else {
            musicControls.bassLevel = 0
        }
        
        if musicControls.brightness > 0.01 {
            musicControls.brightness *= decayRate
        } else {
            musicControls.brightness = 0
        }
        
        // Decay frequency bands - DON'T snap to zero, let them decay naturally
        for i in 0..<musicControls.midLevel.count {
            musicControls.midLevel[i] *= decayRate
        }
        
        for i in 0..<musicControls.highLevel.count {
            musicControls.highLevel[i] *= decayRate
        }
        
        // Slower vocal decay
        if musicControls.vocalPresence > 0.01 {
            musicControls.vocalPresence *= (decayRate * 0.5)
        } else {
            musicControls.vocalPresence = 0
        }
        
        // Metronomic fallback: pulse on beat grid when bass AND vocals are weak
        if musicControls.bassLevel < 0.15 && musicControls.vocalPresence < 0.15 {
            // Get correct clock based on media type
            let nowTime: Double = {
                if self.currentMediaType == .video {
                    return self.videoPlayer?.currentTime().seconds ?? 0
                } else {
                    return self.audioEffectsEngine.currentTime
                }
            }()
            
            let beatInterval = 60.0 / Double(musicControls.currentBPM.clamped(min: 40, max: 240))
            let tolerance = (musicControls.bpmConfidence >= 0.45) ? beatInterval * 0.06 : 0.05
            let phase = nowTime.truncatingRemainder(dividingBy: beatInterval)
            
            if phase <= tolerance || (beatInterval - phase) <= tolerance {
                musicControls.bassLevel = max(musicControls.bassLevel, 0.20)  // Minimum pulse
            }
        }
        
        updateFrequencyBands()
    }
    
    private func updateFrequencyBands() {
        // BALANCED decay - not too fast, not too slow
        let decayFactor: Float = 0.94  // Lose 6% per frame
        
        for i in 0..<3 {
            musicControls.midLevel[i] *= decayFactor
            musicControls.highLevel[i] *= decayFactor
            
            // Soft floor - don't zero out aggressively
            if musicControls.midLevel[i] < 0.02 {
                musicControls.midLevel[i] = 0
            }
            if musicControls.highLevel[i] < 0.02 {
                musicControls.highLevel[i] = 0
            }
        }
    }
    
    // MARK: - Telemetry
    
    func getTelemetryData() -> (droppedFX: Int, avgTriggerSkew: Double) {
        return beatSyncedPlayer?.getTelemetryData() ?? (0, 0)
    }
    
    func resetTelemetry() {
        beatSyncedPlayer?.resetTelemetry()
    }
}

// MARK: - Extensions

private extension Float {
    func clamped(min: Float, max: Float) -> Float {
        Swift.max(min, Swift.min(self, max))
    }
}

