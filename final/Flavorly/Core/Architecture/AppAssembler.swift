//
//  AppAssembler.swift
//  Flavorly
//
//  Created by Brenda Yang on 10/18/25.
//

import Swinject

final class AppAssembler {
    private let assembler: Assembler
    
    var resolver: Resolver {
        self.assembler.resolver
    }
    
    init() {
        self.assembler = Assembler([
            ServiceAssembly(),
            ViewModelAssembly(),
            CoordinatorAssembly()
        ])
    }
}

