//
//  Font+Extensions.swift
//  FlavorlyWidgets
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
        .custom("Boldins", size: size)
    }
    
    // Convenience methods
    static var bakeryTitle3: Font { .bakery(size: 20) }
    static var bakeryHeadline: Font { .bakery(size: 17) }
    static var bakeryBody: Font { .bakery(size: 15) }
    static var bakeryCaption: Font { .bakery(size: 12) }
}
