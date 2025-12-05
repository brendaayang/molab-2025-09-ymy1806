//
//  RecipeListView.swift
//  Flavorly
//
//  Created by Brenda Yang on 9/20/25.
//

import SwiftUI

struct RecipeListView: View {
    @ObservedObject var viewModel: RecipeListViewModel
    @EnvironmentObject var theme: Theme
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.flavorlyCream.ignoresSafeArea()
                
                // Wallpaper background - CONTAINED with better visibility
                GeometryReader { geo in
                    Image(viewModel.currentWallpaper.rawValue)
                        .resizable()
                        .scaledToFill()
                        .frame(width: geo.size.width, height: geo.size.height)
                        .clipped()
                        .opacity(0.5) // Increased opacity so wallpaper is more visible
                }
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: theme.spacing) {
                        if viewModel.recipes.isEmpty {
                            emptyStateView
                        } else {
                            ForEach(viewModel.recipes) { recipe in
                                NavigationLink {
                                    RecipeDetailView(
                                        viewModel: RecipeDetailViewModel(
                                            recipeService: viewModel.recipeService
                                        ),
                                        recipe: recipe
                                    )
                                } label: {
                                    RecipeRowView(recipe: recipe)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("my recipes")
            .navigationBarTitleDisplayMode(.large)
            .background(
                // Subtle pink gradient overlay for more vibes
                LinearGradient(
                    colors: [Color.flavorlyPinkLight.opacity(0.1), Color.clear],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
            )
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        viewModel.showingAddRecipe = true
                    } label: {
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [Color.flavorlyPink, Color.flavorlyPinkDark],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 36, height: 36)
                                .shadow(color: .flavorlyPink.opacity(0.4), radius: 8, x: 0, y: 4)
                            
                            Image(systemName: "plus")
                                .font(Theme.Fonts.bakeryHeadline)
                                .foregroundColor(.white)
                        }
                    }
                }
            }
            .sheet(isPresented: $viewModel.showingAddRecipe) {
                AddRecipeView { name, category, date, notes, links, status, inspirationPhotos in
                    viewModel.addRecipe(
                        name: name,
                        category: category,
                        makeDate: date,
                        notes: notes,
                        links: links,
                        status: status,
                        inspirationPhotos: inspirationPhotos
                    )
                    viewModel.showingAddRecipe = false
                }
            }
            .fullScreenCover(isPresented: $viewModel.showAviArms) {
                AviArmsEasterEgg()
            }
        }
        .accentColor(.flavorlyPink) // Force pink accent color for NavigationView!
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 32) {  // Use actual spacing, not 0
            // Smaller GIF with proper constraints
            GIFImage(name: "melody_heart", contentMode: .scaleAspectFit)
                .frame(width: 50, height: 50)
                .clipped()
                .background(Color.clear)
            
            VStack(spacing: 12) {
                Text("no recipes yet!")
                    .font(Theme.Fonts.bakeryTitle3)
                    .foregroundColor(.flavorlyPinkDark)
                
                Text("grace go bake something damn")
                    .font(Theme.Fonts.bakeryBody)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .background(Color.flavorlyWhite)
        .cornerRadius(theme.cornerRadius)
        .shadow(color: .flavorlyPink.opacity(0.2), radius: 8, x: 0, y: 4)
    }
}

