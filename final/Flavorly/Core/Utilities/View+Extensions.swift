//
//  View+Extensions.swift
//  Flavorly
//
//  Created by Brenda Yang on 10/18/25.
//

import SwiftUI

extension View {
    func pinkNavigationTitle() -> some View {
        self.modifier(PinkNavigationTitleModifier())
    }
}

struct PinkNavigationTitleModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
    }
}

