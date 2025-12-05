//
//  VibeScores.swift
//  Flavorly
//

import Foundation

/// Fast-to-compute musical characteristics
struct VibeScores {
    var bpm: Float
    var bpmConfidence: Float
    
    // Core metrics (all 0...1)
    var energy: Float         // RMS + brightness + beatStrength
    var brightness: Float     // Spectral centroid normalized
    var vocality: Float       // Pitch confidence in 120-800 Hz
    var space: Float          // Reverb/decay tail measure
    var density: Float        // Onsets per beat
    var compression: Float    // 1 - crestFactor (brickwalled vs dynamic)
    var valence: Float        // Major-mode brightness - minor-mode darkness
    
    init(
        bpm: Float = 120,
        bpmConfidence: Float = 0,
        energy: Float = 0.5,
        brightness: Float = 0.5,
        vocality: Float = 0,
        space: Float = 0.5,
        density: Float = 0.5,
        compression: Float = 0.5,
        valence: Float = 0.5
    ) {
        self.bpm = bpm
        self.bpmConfidence = bpmConfidence
        self.energy = energy
        self.brightness = brightness
        self.vocality = vocality
        self.space = space
        self.density = density
        self.compression = compression
        self.valence = valence
    }
}
