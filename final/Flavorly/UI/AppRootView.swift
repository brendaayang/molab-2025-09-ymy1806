//
//  AppRootView.swift
//  Flavorly
//
//  Created by Brenda Yang on 9/19/25.
//

import SwiftUI

struct AppRootView: View {
    @ObservedObject var coordinator: AppRootCoordinator
    @EnvironmentObject var theme: Theme
    @StateObject private var shakeDetector = ShakeDetector()
    @State private var showVampireCouple = false
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Main content
            Group {
                switch coordinator.selectedTab {
                case .recipes:
                    RecipeListView(viewModel: coordinator.makeRecipeListViewModel())
                case .pantry:
                    PantryListView(viewModel: coordinator.makePantryListViewModel())
                case .bakery:
                    OrderListView(viewModel: coordinator.makeOrderListViewModel())
                case .conversions:
                    ConversionsView(viewModel: coordinator.makeConversionsViewModel())
                case .settings:
                    SettingsView(viewModel: coordinator.makeSettingsViewModel(), coordinator: coordinator)
                }
            }
            .safeAreaInset(edge: .bottom) {
                // Reserve space for tab bar
                Color.clear.frame(height: 80)
            }
            
            // Floating custom tab bar (always visible)
            VStack {
                Spacer()
                CustomTabBar(selectedTab: $coordinator.selectedTab)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 30) // More bottom padding
            }
            .ignoresSafeArea(.keyboard)
        }
        .ignoresSafeArea(edges: .bottom)

    }
}

