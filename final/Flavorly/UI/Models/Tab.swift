//
//  Tab.swift
//  Flavorly
//
//  Created by Brenda Yang on 10/18/25.
//

import Foundation

enum Tab: String, CaseIterable {
    case recipes = "recipes"
    case pantry = "pantry"
    case bakery = "my bakery"
    case conversions = "tools"
    case settings = "more stuff"
    
    var icon: String {
        switch self {
        case .recipes:
            return "heart.fill"
        case .pantry:
            return "basket.fill"
        case .bakery:
            return "birthday.cake.fill"
        case .conversions:
            return "hammer.fill"
        case .settings:
            return "star.fill"
        }
    }
}

