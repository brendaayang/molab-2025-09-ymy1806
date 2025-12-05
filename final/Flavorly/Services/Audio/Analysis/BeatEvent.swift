//
//  BeatEvent.swift
//  Flavorly
//
//  Created by Brenda Yang on 10/19/25.
//

import Foundation

enum BeatKind: String, Codable {
    case onset, bass, drop
    // NEW EVENTS
    case chorusStart
    case chorusEnd
    case sectionBoundary
    case vocalIn
    case vocalPhrase
    case buildUp
    case breakdown
    case brightnessSpike
    case sustain
}

struct BeatEvent: Codable, Equatable {
    let t: Double           // seconds from asset start
    let kind: BeatKind
    let strength: Float     // 0..1 (normalized)
    let metadata: [String: Any]?  // Additional data like BPM
    
    init(t: Double, kind: BeatKind, strength: Float, metadata: [String: Any]? = nil) {
        self.t = t
        self.kind = kind
        self.strength = min(max(strength, 0.0), 1.0)  // clamp 0..1
        self.metadata = metadata
    }
    
    // Custom Equatable implementation to handle Any type
    static func == (lhs: BeatEvent, rhs: BeatEvent) -> Bool {
        return lhs.t == rhs.t &&
               lhs.kind == rhs.kind &&
               lhs.strength == rhs.strength &&
               lhs.metadata?.count == rhs.metadata?.count
    }
    
    // Custom Codable implementation to handle Any type
    enum CodingKeys: String, CodingKey {
        case t, kind, strength, metadata
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        t = try container.decode(Double.self, forKey: .t)
        kind = try container.decode(BeatKind.self, forKey: .kind)
        strength = try container.decode(Float.self, forKey: .strength)
        metadata = nil  // Skip metadata for now
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(t, forKey: .t)
        try container.encode(kind, forKey: .kind)
        try container.encode(strength, forKey: .strength)
        // Skip metadata for now
    }
}

// Analyzer configuration
struct BeatAnalyzerConfig: Codable {
    let sampleRate: Float = 44100
    let frameSize: Int = 1024
    let hopSize: Int = 512
    let bassFreqRange: (Float, Float) = (20, 160)
    let fluxWindow: Double = 1.0
    let fluxMultiplier: Float = 1.5
    let bassWindow: Double = 0.5
    let bassMultiplier: Float = 1.3
    let dropThreshold: Float = 0.8
    let version: Int = 1
    
    enum CodingKeys: String, CodingKey {
        case sampleRate, frameSize, hopSize, fluxWindow, fluxMultiplier
        case bassWindow, bassMultiplier, dropThreshold, version
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(sampleRate, forKey: .sampleRate)
        try container.encode(frameSize, forKey: .frameSize)
        try container.encode(hopSize, forKey: .hopSize)
        try container.encode(fluxWindow, forKey: .fluxWindow)
        try container.encode(fluxMultiplier, forKey: .fluxMultiplier)
        try container.encode(bassWindow, forKey: .bassWindow)
        try container.encode(bassMultiplier, forKey: .bassMultiplier)
        try container.encode(dropThreshold, forKey: .dropThreshold)
        try container.encode(version, forKey: .version)
    }
}
