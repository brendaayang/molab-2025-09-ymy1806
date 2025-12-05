//
//  ViewModelAssembly.swift
//  Flavorly
//
//  Created by Brenda Yang on 10/18/25.
//

import Swinject

final class ViewModelAssembly: Assembly {
    func assemble(container: Container) {
        // Recipe List ViewModel
        container.register(RecipeListViewModel.self) { r in
            RecipeListViewModel(
                recipeService: r.resolve(RecipeServiceProtocol.self)!,
                wallpaperService: r.resolve(WallpaperServiceProtocol.self)!
            )
        }
        .inObjectScope(.transient)
        
        // Recipe Detail ViewModel
        container.register(RecipeDetailViewModel.self) { r in
            RecipeDetailViewModel(
                recipeService: r.resolve(RecipeServiceProtocol.self)!
            )
        }
        .inObjectScope(.transient)
        
        // Settings ViewModel
        container.register(SettingsViewModel.self) { r in
            SettingsViewModel(
                wallpaperService: r.resolve(WallpaperServiceProtocol.self)!
            )
        }
        .inObjectScope(.transient)
        
        // Conversions ViewModel
        container.register(ConversionsViewModel.self) { r in
            ConversionsViewModel(
                conversionService: r.resolve(ConversionServiceProtocol.self)!,
                timerService: r.resolve(TimerServiceProtocol.self)!
            )
        }
        .inObjectScope(.transient)
        
        // Order List ViewModel
        container.register(OrderListViewModel.self) { r in
            OrderListViewModel(
                orderService: r.resolve(OrderServiceProtocol.self)!
            )
        }
        .inObjectScope(.transient)
        
        // Order Detail ViewModel
        container.register(OrderDetailViewModel.self) { r in
            OrderDetailViewModel(
                orderService: r.resolve(OrderServiceProtocol.self)!
            )
        }
        .inObjectScope(.transient)
        
        // Pantry List ViewModel
        container.register(PantryListViewModel.self) { r in
            PantryListViewModel(
                pantryService: r.resolve(PantryServiceProtocol.self)!
            )
        }
        .inObjectScope(.transient)
    }
}

