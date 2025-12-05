//
//  VibeMode.swift
//  Flavorly
//

import Foundation

/// Musical vibe/mood classification
enum VibeMode: String, Codable {
    case hype        // High energy, aggressive, club/EDM
    case fastDrive   // High tempo, driving rhythm
    case popBright   // Vocal-forward, major key, uplifting
    case popMoody    // Vocal-forward, minor key, emotional
    case ambient     // Low energy, spacious, calm
    case neutral     // Default/uncertain
    
    var displayName: String {
        switch self {
        case .hype: return "HYPE"
        case .fastDrive: return "FAST"
        case .popBright: return "POP+"
        case .popMoody: return "POP-"
        case .ambient: return "CALM"
        case .neutral: return "—"
        }
    }
    
    /// Visual tuning parameters for this vibe
    var tuning: VibeTuning {
        switch self {
        case .hype, .fastDrive:
            return VibeTuning(
                speakerCap: 0.15,        // More dramatic movement
                barAttackBeats: 0.08,    // Fast & punchy
                barReleaseBeats: 0.5,
                allowParticles: true,
                paletteWarmth: 1.2,      // Warm tint
                saturationBoost: 1.1
            )
        case .ambient:
            return VibeTuning(
                speakerCap: 0.08,        // Subtle movement
                barAttackBeats: 0.15,    // Slow & smooth
                barReleaseBeats: 0.9,
                allowParticles: false,
                paletteWarmth: 0.9,      // Cool tint
                saturationBoost: 0.85    // Desaturated
            )
        case .popBright:
            return VibeTuning(
                speakerCap: 0.12,
                barAttackBeats: 0.10,
                barReleaseBeats: 0.6,
                allowParticles: true,
                paletteWarmth: 1.1,
                saturationBoost: 1.05,
                vocalAuraStrength: 1.3   // Stronger vocal aura
            )
        case .popMoody:
            return VibeTuning(
                speakerCap: 0.12,
                barAttackBeats: 0.10,
                barReleaseBeats: 0.6,
                allowParticles: false,
                paletteWarmth: 0.85,     // Cooler palette
                saturationBoost: 0.95,
                vocalAuraStrength: 1.2,
                vignetteDarkness: 1.15   // Slightly darker
            )
        case .neutral:
            return VibeTuning()  // Defaults
        }
    }
}

/// Visual tuning parameters per vibe
struct VibeTuning {
    var speakerCap: Double = 0.12
    var barAttackBeats: Float = 0.10
    var barReleaseBeats: Float = 0.6
    var allowParticles: Bool = true
    var paletteWarmth: Double = 1.0
    var saturationBoost: Double = 1.0
    var vocalAuraStrength: Double = 1.0
    var vignetteDarkness: Double = 1.0
}
