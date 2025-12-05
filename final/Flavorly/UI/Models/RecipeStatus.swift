//
//  RecipeStatus.swift
//  Flavorly
//
//  Created by Brenda Yang on 10/18/25.
//

import SwiftUI

enum RecipeStatus: String, Codable, CaseIterable {
    case planning = "Planning"
    case inProgress = "In Progress"
    case done = "Done"
    
    var color: Color {
        switch self {
        case .planning:
            return .statusPlanning
        case .inProgress:
            return .statusInProgress
        case .done:
            return .statusDone
        }
    }
    
    var icon: String {
        switch self {
        case .planning:
            return "calendar"
        case .inProgress:
            return "oven"
        case .done:
            return "checkmark.circle.fill"
        }
    }
}

