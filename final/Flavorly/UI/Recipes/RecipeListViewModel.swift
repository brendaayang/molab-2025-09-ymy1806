//
//  RecipeListViewModel.swift
//  Flavorly
//
//  Created by Brenda Yang on 9/20/25.
//

import SwiftUI
import Combine

final class RecipeListViewModel: Bindable, ViewModel {
    let id = UUID()
    
    let recipeService: RecipeServiceProtocol
    private let wallpaperService: WallpaperServiceProtocol
    
    @Published var recipes: [Recipe] = []
    @Published var currentWallpaper: Wallpaper = .wallpaper
    @Published var showingAddRecipe = false
    @Published var showAviArms = false
    
    private let achievementService = AchievementService.shared
    private var achievementCancellable: AnyCancellable?
    
    init(recipeService: RecipeServiceProtocol, wallpaperService: WallpaperServiceProtocol) {
        self.recipeService = recipeService
        self.wallpaperService = wallpaperService
        super.init()
        
        bind()
        
        // Subscribe to recipes
        recipeService.recipes
            .receive(on: DispatchQueue.main)
            .sink { [weak self] recipes in
                self?.recipes = recipes.sorted { $0.createdAt > $1.createdAt }
                self?.checkAchievements()
            }
            .store(in: &cancelBag)
        
        // Subscribe to wallpaper changes
        wallpaperService.currentWallpaper
            .receive(on: DispatchQueue.main)
            .assign(to: &$currentWallpaper)
        
        // Subscribe to achievements
        achievementCancellable = achievementService.onAchievementUnlocked
            .receive(on: DispatchQueue.main)
            .sink { [weak self] achievement in
                if achievement == .twentyRecipes {
                    self?.showAviArms = true
                }
            }
        
        // Check for specific achievements on init
        checkSpecificAchievements()
    }
    
    private func checkAchievements() {
        achievementService.checkRecipeCount(recipes.count)
    }
    
    private func checkSpecificAchievements() {
        // Show Avi Arms for specific achievements, not random
        if achievementService.hasUnlocked(.twentyRecipes) ||
           achievementService.hasUnlocked(.thirteenOrders) ||
           achievementService.hasUnlocked(.twoHundredRevenue) {
            showAviArms = true
        }
    }
    
    func deleteRecipe(_ recipe: Recipe) {
        recipeService.deleteRecipe(recipe)
    }
    
    func addRecipe(name: String, category: String, makeDate: Date?, notes: String, links: [String], status: RecipeStatus, inspirationPhotos: [String]) {
        let recipe = Recipe(
            name: name,
            status: status,
            makeDate: makeDate,
            notes: notes,
            category: category,
            links: links,
            inspirationPhotos: inspirationPhotos
        )
        recipeService.addRecipe(recipe)
    }
}



