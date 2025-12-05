//
//  Font+Extensions.swift
//  Flavorly
//
//  Created by Brenda Yang on 10/18/25.
//

import SwiftUI

extension Font {
    // MARK: - Bakery Font
    static func bakery(size: CGFloat) -> Font {
        .custom("SuperBakery", size: size)
    }
    
    // Boldins Font
    static func boldins(size: CGFloat) -> Font {
        return .custom("Boldins", size: size)
    }
    
    // PressStart2P Font (for iPod screen)
    static func pressStart2P(size: CGFloat) -> Font {
        return .custom("PressStart2P-Regular", size: size)
    }
    
    // Convenience methods for common sizes
    static var bakeryTitle: Font { .bakery(size: 34) }
    static var bakeryTitle2: Font { .bakery(size: 22) }
    static var bakeryTitle3: Font { .bakery(size: 20) }
    static var bakeryHeadline: Font { .bakery(size: 17) }
    static var bakeryBody: Font { .bakery(size: 17) }
    
    static var boldinsTitle: Font { .boldins(size: 28) }
    static var boldinsTitle2: Font { .boldins(size: 22) }
    static var boldinsTitle3: Font { .boldins(size: 20) }
    static var boldinsHeadline: Font { .boldins(size: 17) }
    static var boldinsBody: Font { .boldins(size: 17) }
}

