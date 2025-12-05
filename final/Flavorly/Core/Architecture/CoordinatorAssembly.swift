//
//  CoordinatorAssembly.swift
//  Flavorly
//
//  Created by Brenda Yang on 10/18/25.
//

import Swinject

final class CoordinatorAssembly: Assembly {
    func assemble(container: Container) {
        // App Root Coordinator
        container.register(AppRootCoordinator.self) { r in
            AppRootCoordinator(resolver: r)
        }
        .inObjectScope(.container)
    }
}

