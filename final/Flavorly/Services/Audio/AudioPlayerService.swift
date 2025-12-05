//
//  AudioPlayerService.swift
//  Flavorly
//
//  Created by Brenda Yang on 10/18/25.
//

import AVFoundation
import Foundation
import UIKit

final class AudioPlayerService {
    static let shared = AudioPlayerService()
    
    private var audioPlayer: AVAudioPlayer?
    private let duration: TimeInterval = 15.0  // Play for 15 seconds
    private var playbackTimer: Timer?
    
    // Song configuration: [songName: startTime]
    private let songTimestamps: [String: TimeInterval] = [
        "ecstacy": 7.0,   // 0:07
        "lacerate": 54.0, // 0:54
        "kiss": 72.0,     // 1:12
        "under": 20.0,    // 0:20
        "passion": 16.0   // 0:16
    ]
    
    private var availableSongs: [String] {
        Array(songTimestamps.keys)
    }
    
    private init() {
        // Audio will be loaded when needed
        setupNotifications()
    }
    
    deinit {
        cleanup()
    }
    
    private func setupNotifications() {
        // Clean up audio when app goes to background
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(cleanup),
            name: UIApplication.willResignActiveNotification,
            object: nil
        )
    }
    
    private func loadRandomSong() -> String? {
        // Pick a random song
        guard let randomSong = availableSongs.randomElement() else {
            print("❌ No songs available")
            return nil
        }
        
        guard let url = Bundle.main.url(forResource: randomSong, withExtension: "mp3") else {
            print("❌ Failed to find \(randomSong).mp3")
            return nil
        }
        
        do {
            // Clean up existing player first
            stopAudio()
            
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.prepareToPlay()
            print("✅ Loaded: \(randomSong).mp3")
            return randomSong
        } catch {
            print("❌ Failed to load \(randomSong).mp3: \(error)")
            return nil
        }
    }
    
    func playEcstasySegment() {
        // Load a random song
        guard let songName = loadRandomSong(),
              let player = audioPlayer,
              let startTime = songTimestamps[songName] else {
            print("❌ Failed to load song")
            return
        }
        
        // Configure audio session
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("❌ Audio session error: \(error)")
            return
        }
        
        // Random pitch variation (-2.0 to -1.2 semitones, much deeper)
        let pitchVariation = Float.random(in: -2.0...(-1.2))
        player.enableRate = true
        player.rate = pow(2.0, pitchVariation / 12.0) // Convert semitones to playback rate
        
        // Set start time and play
        player.currentTime = startTime
        player.volume = 0.7
        player.play()
        
        print("🎵 Playing \(songName).mp3 from \(startTime)s with pitch: \(pitchVariation) semitones, rate: \(player.rate)")
        
        // Schedule cleanup after duration
        playbackTimer?.invalidate()
        playbackTimer = Timer.scheduledTimer(withTimeInterval: duration, repeats: false) { [weak self] _ in
            self?.stopAudio()
        }
    }
    
    func stopAudio() {
        playbackTimer?.invalidate()
        playbackTimer = nil
        
        audioPlayer?.stop()
        audioPlayer = nil
        
        // Deactivate audio session
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
    }
    
    @objc private func cleanup() {
        stopAudio()
        NotificationCenter.default.removeObserver(self)
    }
}

