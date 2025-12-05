//
//  RecipeService.swift
//  Flavorly
//
//  Created by Brenda Yang on 10/18/25.
//

import Combine
import Foundation

final class RecipeService: RecipeServiceProtocol {
    private let storageService: StorageServiceProtocol
    private let recipesKey = "recipes"
    
    private let _recipes: CurrentValueSubject<[Recipe], Never>
    var recipes: AnyPublisher<[Recipe], Never> {
        _recipes.eraseToAnyPublisher()
    }
    
    init(storageService: StorageServiceProtocol) {
        self.storageService = storageService
        
        // Load saved recipes or use empty array
        let saved: [Recipe]? = storageService.getValue(forKey: recipesKey)
        self._recipes = CurrentValueSubject(saved ?? [])
    }
    
    func addRecipe(_ recipe: Recipe) {
        var currentRecipes = _recipes.value
        currentRecipes.append(recipe)
        save(currentRecipes)
    }
    
    func updateRecipe(_ recipe: Recipe) {
        var currentRecipes = _recipes.value
        if let index = currentRecipes.firstIndex(where: { $0.id == recipe.id }) {
            currentRecipes[index] = recipe
            save(currentRecipes)
        }
    }
    
    func deleteRecipe(_ recipe: Recipe) {
        var currentRecipes = _recipes.value
        currentRecipes.removeAll { $0.id == recipe.id }
        save(currentRecipes)
    }
    
    func getRecipes() -> [Recipe] {
        _recipes.value
    }
    
    private func save(_ recipes: [Recipe]) {
        storageService.setValue(recipes, forKey: recipesKey)
        _recipes.send(recipes)
    }
}

