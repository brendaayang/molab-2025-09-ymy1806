//
//  TimerActivityAttributes.swift
//  FlavorlyWidgets
//
//  Created by Brenda Yang on 10/18/25.
//

import Foundation
import ActivityKit

struct TimerActivityAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable, Equatable {
        var timerName: String
        var endTime: Date
        var isCompleted: Bool
        var timerColor: String // Store as string for Codable
        
        init(timerName: String, endTime: Date, isCompleted: Bool, timerColor: String) {
            self.timerName = timerName
            self.endTime = endTime
            self.isCompleted = isCompleted
            self.timerColor = timerColor
        }
    }
    
    var timerName: String
    var timerColor: String
}
