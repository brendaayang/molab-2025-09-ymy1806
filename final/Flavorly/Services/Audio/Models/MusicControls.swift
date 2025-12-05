//
//  MusicControls.swift
//  Flavorly
//
//  Created by Brenda Yang on 10/19/25.
//

import Foundation

struct MusicControls {
    // Continuous parameters (0...1)
    var bassLevel: Float = 0
    var midLevel: [Float] = [0, 0, 0]    // Bands 3-5 (250, 500, 1000 Hz)
    var highLevel: [Float] = [0, 0, 0]   // Bands 6-8 (2000, 4000, 8000 Hz)
    var brightness: Float = 0             // Spectral centroid normalized
    var vocalPresence: Float = 0          // EMA of vocal detection
    
    // Mode flags with hysteresis
    var isChorus: Bool = false
    var isBuildUp: Bool = false
    var chorusHoldTime: Double = 0
    var chorusOffTime: Double = 0
    
    // Transient flags (one-shot, reset each frame)
    var didOnset: Bool = false
    var didDrop: Bool = false
    var didSectionBoundary: Bool = false
    var didBrightnessSpike: Bool = false
    
    // BPM tracking
    var currentBPM: Float = 120
    var bpmConfidence: Float = 0
    
    // Vibe tracking (locked for entire track)
    var currentVibe: VibeMode = .neutral
    var vibeConfidence: Float = 0.0
    var vibePhase: VibePhase = .collecting
    
    // Timing
    var lastUpdateTime: Double = 0
    
    // Reset all parameters to initial state
    mutating func reset() {
        bassLevel = 0
        midLevel = [0, 0, 0]
        highLevel = [0, 0, 0]
        brightness = 0
        vocalPresence = 0
        isChorus = false
        isBuildUp = false
        chorusHoldTime = 0
        chorusOffTime = 0
        didOnset = false
        didDrop = false
        didSectionBoundary = false
        didBrightnessSpike = false
        currentBPM = 120
        bpmConfidence = 0
        currentVibe = .neutral
        vibeConfidence = 0.0
        vibePhase = .collecting
        lastUpdateTime = 0
    }
}
