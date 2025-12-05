//
//  OrderStatus.swift
//  Flavorly
//
//  Created by Brenda Yang on 10/18/25.
//

import SwiftUI

enum OrderStatus: String, Codable, CaseIterable {
    case pending = "Pending"
    case baking = "Baking"
    case ready = "Ready"
    case completed = "Completed"
    
    var color: Color {
        switch self {
        case .pending:
            return Color.orange
        case .baking:
            return Color.flavorlyPurple
        case .ready:
            return Color.flavorlyPink
        case .completed:
            return Color.green
        }
    }
    
    var icon: String {
        switch self {
        case .pending:
            return "clock.fill"
        case .baking:
            return "flame.fill"
        case .ready:
            return "checkmark.circle.fill"
        case .completed:
            return "gift.fill"
        }
    }
}

