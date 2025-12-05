//
//  BakingTimer.swift
//  Flavorly
//
//  Created by Brenda Yang on 10/18/25.
//

import Foundation

struct BakingTimer: Identifiable, Codable, Hashable {
    var id: UUID
    var name: String
    var duration: TimeInterval
    var endTime: Date
    var isActive: Bool
    var isPaused: Bool
    var color: TimerColor
    var createdAt: Date
    
    init(
        id: UUID = UUID(),
        name: String,
        duration: TimeInterval,
        color: TimerColor = .pink,
        isActive: Bool = true,
        isPaused: Bool = false
    ) {
        self.id = id
        self.name = name
        self.duration = duration
        self.endTime = Date().addingTimeInterval(duration)
        self.isActive = isActive
        self.isPaused = isPaused
        self.color = color
        self.createdAt = Date()
    }
    
    var remainingTime: TimeInterval {
        guard isActive, !isPaused else { return duration }
        let remaining = endTime.timeIntervalSinceNow
        return max(0, remaining)
    }
    
    var isCompleted: Bool {
        return remainingTime <= 0 && isActive
    }
    
    var progress: Double {
        guard duration > 0 else { return 0 }
        let elapsed = duration - remainingTime
        return min(1.0, max(0.0, elapsed / duration))
    }
    
    func formattedRemainingTime() -> String {
        let remaining = Int(remainingTime)
        let hours = remaining / 3600
        let minutes = (remaining % 3600) / 60
        let seconds = remaining % 60
        
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%d:%02d", minutes, seconds)
        }
    }
}

enum TimerColor: String, Codable, CaseIterable, Hashable {
    case pink = "pink"
    case rose = "rose"
    case peach = "peach"
    case lavender = "lavender"
    
    var displayName: String {
        return rawValue
    }
}

enum TimerPreset: String, CaseIterable {
    case proofing = "proofing (1h)"
    case baking = "baking (25m)"
    case cooling = "cooling (15m)"
    case chilling = "chilling (2h)"
    case freezing = "freezing (4h)"
    case custom = "custom"
    
    var duration: TimeInterval {
        switch self {
        case .proofing:
            return 3600 // 1 hour
        case .baking:
            return 1500 // 25 minutes
        case .cooling:
            return 900 // 15 minutes
        case .chilling:
            return 7200 // 2 hours
        case .freezing:
            return 14400 // 4 hours
        case .custom:
            return 0
        }
    }
    
    var icon: String {
        switch self {
        case .proofing:
            return "clock.arrow.circlepath"
        case .baking:
            return "flame.fill"
        case .cooling:
            return "snowflake"
        case .chilling:
            return "thermometer.low"
        case .freezing:
            return "wind.snow"
        case .custom:
            return "clock.fill"
        }
    }
}

