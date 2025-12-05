//
//  VibeEstimator.swift
//  Flavorly
//

import Foundation

/// Phase of vibe detection state machine
enum VibePhase: Equatable {
    case collecting           // Gathering initial data
    case probation           // Extended data collection (one chance)
    case locked(VibeMode)    // Decision made, frozen for track
}

/// Estimates and locks musical vibe for entire track
final class VibeEstimator {
    // MARK: - State
    
    private(set) var phase: VibePhase = .collecting
    private var startTime: Double = 0
    private var decidedAt: Double = 0
    private var relockUsed: Bool = false
    private var currentAssetKey: String?
    private var beatsAccumulated: Double = 0
    
    // MARK: - Configuration
    
    private let minWarmupSeconds: Double = 12.0
    private let minWarmupBeats: Double = 16.0
    private let probationExtensionBeats: Double = 8.0
    private let decisionConfidenceThreshold: Float = 0.55
    private let decisionMarginThreshold: Float = 0.15
    private let relockTimeWindow: Double = 10.0
    private let relockMaxTime: Double = 25.0
    private let relockConfidenceThreshold: Float = 0.65
    private let relockMarginThreshold: Float = 0.35
    
    // MARK: - Public API
    
    /// Start tracking a new asset
    func start(assetKey: String, startTime: Double) {
        print("🎭 VibeEstimator: Starting for asset \(assetKey)")
        self.currentAssetKey = assetKey
        self.phase = .collecting
        self.startTime = startTime
        self.decidedAt = 0
        self.relockUsed = false
        self.beatsAccumulated = 0
    }
    
    /// Update with new analysis data
    func update(currentTime: Double, beatsElapsed: Double, scores: VibeScores) {
        beatsAccumulated = beatsElapsed
        let elapsed = currentTime - startTime
        
        switch phase {
        case .collecting:
            if readyToDecide(elapsed: elapsed, beats: beatsElapsed) {
                let (mode, conf, margin) = pickMode(scores, isEarly: true)
                
                print("🎭 VibeEstimator: Initial decision - \(mode.rawValue) conf=\(String(format: "%.2f", conf)) margin=\(String(format: "%.2f", margin))")
                
                if conf >= decisionConfidenceThreshold && margin >= decisionMarginThreshold {
                    phase = .locked(mode)
                    decidedAt = currentTime
                    print("✅ VibeEstimator: LOCKED to \(mode.displayName) after \(String(format: "%.1f", elapsed))s")
                } else {
                    phase = .probation
                    print("⏸ VibeEstimator: Probation - extending warmup by \(probationExtensionBeats) beats")
                }
            }
            
        case .probation:
            let extendedBeats = minWarmupBeats + probationExtensionBeats
            if readyToDecide(elapsed: elapsed, beats: beatsElapsed, requiredBeats: extendedBeats) {
                let (mode, conf, margin) = pickMode(scores, isEarly: true)
                phase = .locked(mode)
                decidedAt = currentTime
                print("✅ VibeEstimator: LOCKED to \(mode.displayName) after probation (\(String(format: "%.1f", elapsed))s, conf=\(String(format: "%.2f", conf)))")
            }
            
        case .locked(let currentMode):
            // Optional single relock window
            let timeSinceDecision = currentTime - decidedAt
            let totalTime = currentTime - startTime
            
            if !relockUsed && timeSinceDecision <= relockTimeWindow && totalTime <= relockMaxTime {
                let (newMode, newConf, newMargin) = pickMode(scores, isEarly: false)
                
                if newMode != currentMode && newConf >= relockConfidenceThreshold && newMargin >= relockMarginThreshold {
                    phase = .locked(newMode)
                    relockUsed = true
                    decidedAt = currentTime
                    print("🔄 VibeEstimator: RELOCK from \(currentMode.displayName) → \(newMode.displayName) (conf=\(String(format: "%.2f", newConf)))")
                }
            }
            // else: stay locked, ignore further updates
        }
    }
    
    /// Get current locked vibe mode (if any)
    var currentMode: VibeMode? {
        if case .locked(let mode) = phase {
            return mode
        }
        return nil
    }
    
    /// Get current vibe for display (neutral if not locked)
    var displayMode: VibeMode {
        currentMode ?? .neutral
    }
    
    // MARK: - Private Logic
    
    private func readyToDecide(elapsed: Double, beats: Double, requiredBeats: Double? = nil) -> Bool {
        let minBeats = requiredBeats ?? minWarmupBeats
        return elapsed >= minWarmupSeconds || beats >= minBeats
    }
    
    private func pickMode(_ scores: VibeScores, isEarly: Bool) -> (mode: VibeMode, confidence: Float, margin: Float) {
        // Compute per-mode scores
        let hypeScore = clamp(0.5 * scores.energy + 0.3 * scores.density + 0.2 * scores.compression)
        let ambientScore = clamp((1 - scores.energy) * 0.5 + scores.space * 0.4 + (1 - scores.valence) * 0.2)
        let popBrightScore = clamp(scores.vocality * 0.6 + scores.valence * 0.4)
        let popMoodyScore = clamp(scores.vocality * 0.6 + (1 - scores.valence) * 0.4)
        let fastDriveScore = clamp((scores.bpm > 160 ? 0.6 : 0.0) + scores.density * 0.4)
        let neutralScore: Float = 0.3
        
        let candidates: [(VibeMode, Float)] = [
            (.hype, hypeScore),
            (.ambient, ambientScore),
            (.popBright, popBrightScore),
            (.popMoody, popMoodyScore),
            (.fastDrive, fastDriveScore),
            (.neutral, neutralScore)
        ]
        
        // Sort by score descending
        let sorted = candidates.sorted { $0.1 > $1.1 }
        let winner = sorted[0]
        let runnerUp = sorted[1]
        
        let margin = winner.1 - runnerUp.1
        
        // Temper confidence by BPM confidence early to avoid overcommitting
        let bpmFactor: Float = isEarly ? (0.7 + 0.3 * scores.bpmConfidence) : 1.0
        let adjustedConfidence = clamp(winner.1 * bpmFactor)
        
        return (winner.0, adjustedConfidence, margin)
    }
    
    private func clamp(_ value: Float, min: Float = 0, max: Float = 1) -> Float {
        Swift.min(Swift.max(value, min), max)
    }
}
