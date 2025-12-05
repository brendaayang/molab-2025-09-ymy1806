//
//  AppRootCoordinator.swift
//  Flavorly
//
//  Created by Brenda Yang on 10/18/25.
//

import SwiftUI
import Swinject

final class AppRootCoordinator: ObservableObject {
    private let resolver: Resolver
    
    @Published var selectedTab: Tab = .recipes
    
    init(resolver: Resolver) {
        self.resolver = resolver
    }
    
    func makeRecipeListViewModel() -> RecipeListViewModel {
        resolver.resolve(RecipeListViewModel.self)!
    }
    
    func makeRecipeDetailViewModel() -> RecipeDetailViewModel {
        resolver.resolve(RecipeDetailViewModel.self)!
    }
    
    func makeSettingsViewModel() -> SettingsViewModel {
        resolver.resolve(SettingsViewModel.self)!
    }
    
    func makeConversionsViewModel() -> ConversionsViewModel {
        resolver.resolve(ConversionsViewModel.self)!
    }
    
    func makeOrderListViewModel() -> OrderListViewModel {
        resolver.resolve(OrderListViewModel.self)!
    }
    
    func makePantryListViewModel() -> PantryListViewModel {
        resolver.resolve(PantryListViewModel.self)!
    }
}

