//
//  AppAppearanceService.swift
//  Flavorly
//
//  Created by Brenda Yang on 10/18/25.
//

import SwiftUI

final class AppAppearanceService: AppAppearanceServiceProtocol {
    private let tabBarBackground = Color.flavorlyCream
    private let navBarBackground = Color.flavorlyCream
    private let tabItemDefault = Color.gray.opacity(0.5)
    private let tabItemSelected = Color.flavorlyPink
    private let separatorColor = Color(uiColor: .separator)
    
    func configureCustomFonts() {
        // Fonts are registered via Info.plist (UIAppFonts key)
        print("✅ Custom fonts configured")
    }
    
    func configureTabBarAppearance() {
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithOpaqueBackground()
        
        tabBarAppearance.backgroundColor = tabBarBackground.uiColor
        tabBarAppearance.shadowImage = UIImage()
        tabBarAppearance.shadowColor = separatorColor.uiColor
        
        updateTabBarItemAppearance(appearance: tabBarAppearance.compactInlineLayoutAppearance)
        updateTabBarItemAppearance(appearance: tabBarAppearance.inlineLayoutAppearance)
        updateTabBarItemAppearance(appearance: tabBarAppearance.stackedLayoutAppearance)
        
        UITabBar.appearance().standardAppearance = tabBarAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
    }
    
    private func updateTabBarItemAppearance(appearance: UITabBarItemAppearance) {
        appearance.normal.iconColor = tabItemDefault.uiColor
        appearance.selected.iconColor = tabItemSelected.uiColor
        appearance.selected.titleTextAttributes = [
            NSAttributedString.Key.foregroundColor: tabItemSelected.uiColor
        ]
    }
    
    func configureNavBarAppearance() {
        // This is now handled globally in AppDelegate.swift
    }
}



