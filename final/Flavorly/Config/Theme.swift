//
//  Theme.swift
//  Flavorly
//
//  Created by Brenda Yang on 9/23/25.
//

import SwiftUI

class Theme: ObservableObject {
    static let shared = Theme()
    
    @Published var mode: ColorScheme = .light
    
    // MARK: - Pink My Melody Theme Colors
    let primaryPink = Color.flavorlyPink
    let lightPink = Color.flavorlyPinkLight
    let darkPink = Color.flavorlyPinkDark
    let purple = Color.flavorlyPurple
    let rose = Color.flavorlyRose
    let cream = Color.flavorlyCream
    let white = Color.flavorlyWhite
    
    // MARK: - UI Constants
    let cornerRadius: CGFloat = 20
    let smallCornerRadius: CGFloat = 12
    let cardPadding: CGFloat = 16
    let spacing: CGFloat = 12
    
    // MARK: - Font Sizes (Using Custom Fonts)
    struct Fonts {
        // Bakery Font
        static let bakeryTitle: Font = .bakery(size: 28)
        static let bakeryTitle2: Font = .bakery(size: 24)
        static let bakeryTitle3: Font = .bakery(size: 22)
        static let bakeryHeadline: Font = .bakery(size: 20)
        static let bakeryBody: Font = .bakery(size: 17)
        static let bakerySubheadline: Font = .bakery(size: 16)
        static let bakeryCaption: Font = .bakery(size: 14)
        static let bakerySmall: Font = .bakery(size: 12)
        
        // Boldins Font
        static let boldinsTitle: Font = .boldins(size: 28)
        static let boldinsTitle2: Font = .boldins(size: 24)
        static let boldinsTitle3: Font = .boldins(size: 22)
        static let boldinsHeadline: Font = .boldins(size: 20)
        static let boldinsBody: Font = .boldins(size: 17)
        static let boldinsSubheadline: Font = .boldins(size: 16)
        static let boldinsCaption: Font = .boldins(size: 14)
        
        // Mixed - Price/Money Display
        static let priceFont: Font = .boldins(size: 24)
        static let priceFontLarge: Font = .boldins(size: 32)
    }
    
    private init() {}
}

