//
//  CustomTabBar.swift
//  Flavorly
//
//  Created by Brenda Yang on 9/19/25.
//

import SwiftUI
import UIKit

struct CustomTabBar: View {
    @Binding var selectedTab: Tab
    @EnvironmentObject var theme: Theme
    @State private var settingsTapCount = 0
    @State private var showAviArms = false
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(Tab.allCases, id: \.self) { tab in
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selectedTab = tab
                    }
                    
                    // Haptic feedback
                    let generator = UIImpactFeedbackGenerator(style: .light)
                    generator.impactOccurred()
                    
                    // Triple-tap on Settings for easter egg
                    if tab == .settings {
                        settingsTapCount += 1
                        if settingsTapCount >= 3 {
                            showAviArms = true
                            settingsTapCount = 0
                        }
                        
                        // Reset count after 1 second
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            settingsTapCount = 0
                        }
                    }
                } label: {
                    VStack(spacing: 4) { // Tighter spacing
                            Image(systemName: tab.icon)
                                .font(Theme.Fonts.bakeryBody) // Use theme font
                            .foregroundColor(selectedTab == tab ? .white : .white.opacity(0.6))
                            .scaleEffect(selectedTab == tab ? 1.1 : 1.0)
                            .shadow(color: selectedTab == tab ? .white.opacity(0.4) : .clear, radius: 6, x: 0, y: 0)
                        
                        Text(tab.rawValue)
                            .font(.custom("SuperBakery", size: 10)) // Custom font!
                            .foregroundColor(selectedTab == tab ? .white : .white.opacity(0.7))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(selectedTab == tab ? Color.flavorlyPinkDark.opacity(0.4) : Color.clear)
                    )
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(
            LinearGradient(
                colors: [Color.flavorlyPink, Color.flavorlyPinkDark],
                startPoint: .leading,
                endPoint: .trailing
            )
            .clipShape(RoundedRectangle(cornerRadius: 30)) // More rounded
            .shadow(color: .flavorlyPink.opacity(0.5), radius: 20, x: 0, y: 8)
        )
        .fullScreenCover(isPresented: $showAviArms) {
            AviArmsEasterEgg()
        }
    }
}

