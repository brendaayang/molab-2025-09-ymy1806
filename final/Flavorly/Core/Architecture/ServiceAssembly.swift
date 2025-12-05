//
//  ServiceAssembly.swift
//  Flavorly
//
//  Created by Brenda Yang on 10/18/25.
//

import Swinject
import Foundation

final class ServiceAssembly: Assembly {
    func assemble(container: Container) {
        // Storage Service
        container.register(StorageServiceProtocol.self) { _ in
            StorageService()
        }
        .inObjectScope(.container)
        
        // Wallpaper Service
        container.register(WallpaperServiceProtocol.self) { r in
            WallpaperService(storageService: r.resolve(StorageServiceProtocol.self)!)
        }
        .inObjectScope(.container)
        
        // Recipe Service
        container.register(RecipeServiceProtocol.self) { r in
            RecipeService(storageService: r.resolve(StorageServiceProtocol.self)!)
        }
        .inObjectScope(.container)
        
        // Tab Service
        container.register(TabServiceProtocol.self) { _ in
            TabService()
        }
        .inObjectScope(.container)
        
        // App Appearance Service
        container.register(AppAppearanceServiceProtocol.self) { _ in
            AppAppearanceService()
        }
        .inObjectScope(.container)
        
        // Conversion Service
        container.register(ConversionServiceProtocol.self) { _ in
            ConversionService()
        }
        .inObjectScope(.container)
        
        // Order Service
        container.register(OrderServiceProtocol.self) { r in
            OrderService(storageService: r.resolve(StorageServiceProtocol.self)!)
        }
        .inObjectScope(.container)
        
        // Pantry Service
        container.register(PantryServiceProtocol.self) { r in
            PantryService(storageService: r.resolve(StorageServiceProtocol.self)!)
        }
        .inObjectScope(.container)
        
        // Timer Service
        container.register(TimerServiceProtocol.self) { _ in
            TimerService()
        }
        .inObjectScope(.container)
    }
}

