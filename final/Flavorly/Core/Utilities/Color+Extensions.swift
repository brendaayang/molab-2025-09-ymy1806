//
//  Color+Extensions.swift
//  Flavorly
//
//  Created by Brenda Yang on 10/18/25.
//

import SwiftUI

extension Color {
    // MARK: - Pink Theme Colors
    static let flavorlyPink = Color(red: 0.98, green: 0.75, blue: 0.83) // #FAC0D3
    static let flavorlyPinkLight = Color(red: 1.0, green: 0.89, blue: 0.93) // #FFE3ED
    static let flavorlyPinkDark = Color(red: 0.93, green: 0.51, blue: 0.68) // #ED82AD
    static let flavorlyPurple = Color(red: 0.85, green: 0.71, blue: 0.93) // #D9B5ED
    static let flavorlyRose = Color(red: 0.96, green: 0.64, blue: 0.71) // #F5A3B5
    static let flavorlyCream = Color(red: 1.0, green: 0.98, blue: 0.94) // #FFFAF0
    static let flavorlyWhite = Color(red: 1.0, green: 0.99, blue: 0.98) // #FFFCFA
    
    // MARK: - Status Colors
    static let statusPlanning = Color.flavorlyPink
    static let statusInProgress = Color.flavorlyPurple
    static let statusDone = Color.flavorlyRose
    
    // MARK: - UIColor Conversion
    var uiColor: UIColor {
        UIColor(self)
    }
}

