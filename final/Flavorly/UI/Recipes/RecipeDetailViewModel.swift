//
//  RecipeDetailViewModel.swift
//  Flavorly
//
//  Created by Brenda Yang on 10/18/25.
//

import SwiftUI
import Combine

final class RecipeDetailViewModel: Bindable, ViewModel {
    let id = UUID()
    
    private let recipeService: RecipeServiceProtocol
    
    @Published var recipe: Recipe
    @Published var isEditing = false
    
    init(recipeService: RecipeServiceProtocol) {
        self.recipeService = recipeService
        // Will be set from the view
        self.recipe = Recipe(name: "", status: .planning)
        super.init()
        bind()
    }
    
    func updateRecipe(_ updatedRecipe: Recipe) {
        self.recipe = updatedRecipe
        recipeService.updateRecipe(updatedRecipe)
    }
}

