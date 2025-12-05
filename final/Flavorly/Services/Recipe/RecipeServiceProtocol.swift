//
//  RecipeServiceProtocol.swift
//  Flavorly
//
//  Created by Brenda Yang on 10/18/25.
//

import Combine

protocol RecipeServiceProtocol {
    var recipes: AnyPublisher<[Recipe], Never> { get }
    func addRecipe(_ recipe: Recipe)
    func updateRecipe(_ recipe: Recipe)
    func deleteRecipe(_ recipe: Recipe)
    func getRecipes() -> [Recipe]
}

