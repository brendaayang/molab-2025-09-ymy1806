//
//  Wallpaper.swift
//  Flavorly
//
//  Created by Brenda Yang on 10/18/25.
//

import Foundation

enum Wallpaper: String, Codable, CaseIterable {
    case wallpaper = "wallpaper"
    case wallpaper2 = "wallpaper2"
    case wallpaper3 = "wallpaper3"
    case wallpaper4 = "wallpaper4"
    case wallpaper5 = "wallpaper5"
    case wallpaper6 = "wallpaper6"
    case wallpaper7 = "wallpaper7"
    case wallpaper8 = "wallpaper8"
    
    var displayName: String {
        switch self {
        case .wallpaper:
            return "Pink Blossoms"
        case .wallpaper2:
            return "Sweet Dreams"
        case .wallpaper3:
            return "Candy Hearts"
        case .wallpaper4:
            return "Bubblegum Clouds"
        case .wallpaper5:
            return "Cotton Candy"
        case .wallpaper6:
            return "Strawberry Cream"
        case .wallpaper7:
            return "Rose Garden"
        case .wallpaper8:
            return "Cherry Blossoms"
        }
    }
    
    // Randomized order for display
    static var shuffled: [Wallpaper] {
        allCases.shuffled()
    }
}

