//
//  RecipeDetailView.swift
//  Flavorly
//
//  Created by Brenda Yang on 10/18/25.
//

import SwiftUI

struct RecipeDetailView: View {
    @ObservedObject var viewModel: RecipeDetailViewModel
    @State var recipe: Recipe
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var theme: Theme
    
    @State private var isEditing = false
    @State private var editedName: String
    @State private var editedCategory: String
    @State private var editedNotes: String
    @State private var editedLinks: [String]
    @State private var editedStatus: RecipeStatus
    @State private var editedMakeDate: Date?
    @State private var hasDate: Bool
    @State private var editedInspirationPhotos: [UIImage] = []
    @State private var newPhotos: [UIImage] = [] // Temporary array for new photos
    @State private var showingImagePicker = false
    @State private var showingCamera = false
    @State private var showingSummary = false
    
    init(viewModel: RecipeDetailViewModel, recipe: Recipe) {
        self.viewModel = viewModel
        self.recipe = recipe
        _editedName = State(initialValue: recipe.name)
        _editedCategory = State(initialValue: recipe.category)
        _editedNotes = State(initialValue: recipe.notes)
        _editedLinks = State(initialValue: recipe.links)
        _editedStatus = State(initialValue: recipe.status)
        _editedMakeDate = State(initialValue: recipe.makeDate)
        _hasDate = State(initialValue: recipe.makeDate != nil)
        
        // Load existing photos
        let photos = recipe.inspirationPhotos.compactMap { base64 -> UIImage? in
            guard let data = Data(base64Encoded: base64) else { return nil }
            return UIImage(data: data)
        }
        _editedInspirationPhotos = State(initialValue: photos)
    }
    
    var body: some View {
        ZStack {
            Color.flavorlyCream.ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Header card
                    VStack(alignment: .leading, spacing: 12) {
                        if isEditing {
                            TextField("Recipe Name", text: $editedName)
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(.flavorlyPinkDark)
                        } else {
                            Text(recipe.name)
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(.flavorlyPinkDark)
                        }
                        
                        if isEditing {
                            TextField("Category", text: $editedCategory)
                                .font(.subheadline)
                        } else if !recipe.category.isEmpty {
                            Text(recipe.category)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.flavorlyWhite)
                    .cornerRadius(theme.cornerRadius)
                    .shadow(color: .flavorlyPink.opacity(0.2), radius: 8, x: 0, y: 4)
                    
                    // Status card with capsule
                    VStack(alignment: .leading, spacing: 12) {
                        Text("status")
                            .font(Theme.Fonts.bakeryHeadline)
                            .foregroundColor(.flavorlyPinkDark)
                        
                        CustomStatusSelector(selectedStatus: $editedStatus) { newStatus in
                            var updatedRecipe = recipe
                            updatedRecipe.status = newStatus
                            viewModel.updateRecipe(updatedRecipe)
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.flavorlyWhite)
                    .cornerRadius(theme.cornerRadius)
                    .shadow(color: .flavorlyPink.opacity(0.2), radius: 8, x: 0, y: 4)
                    
                    // Date card
                    VStack(alignment: .leading, spacing: 12) {
                        Text("make date")
                            .font(Theme.Fonts.bakeryHeadline)
                            .foregroundColor(.flavorlyPinkDark)
                        
                        if isEditing {
                            Toggle("Set Date", isOn: $hasDate)
                            
                            if hasDate {
                                DatePicker(
                                    "Make Date",
                                    selection: Binding(
                                        get: { editedMakeDate ?? Date() },
                                        set: { editedMakeDate = $0 }
                                    ),
                                    displayedComponents: .date
                                )
                                .datePickerStyle(GraphicalDatePickerStyle())
                                .accentColor(.flavorlyPink)
                            }
                        } else {
                            if let makeDate = recipe.makeDate {
                                Text(makeDate, style: .date)
                                    .font(.body)
                            } else {
                                Text("Not set")
                                    .font(.body)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.flavorlyWhite)
                    .cornerRadius(theme.cornerRadius)
                    .shadow(color: .flavorlyPink.opacity(0.2), radius: 8, x: 0, y: 4)
                    
                        // Links card
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("recipe links")
                                    .font(Theme.Fonts.bakeryHeadline)
                                    .foregroundColor(.flavorlyPinkDark)
                                
                                Spacer()
                                
                                if isEditing {
                                    Button {
                                        editedLinks.append("")
                                    } label: {
                                        Image(systemName: "plus.circle.fill")
                                            .foregroundColor(.flavorlyPink)
                                    }
                                }
                            }
                        
                        if isEditing {
                            ForEach(editedLinks.indices, id: \.self) { index in
                                HStack {
                                    TextField("https://...", text: $editedLinks[index])
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                        .autocapitalization(.none)
                                        .keyboardType(.URL)
                                    
                                    Button {
                                        editedLinks.remove(at: index)
                                    } label: {
                                        Image(systemName: "minus.circle.fill")
                                            .foregroundColor(.red)
                                    }
                                }
                            }
                        } else {
                            if recipe.links.isEmpty {
                                Text("no links added")
                                    .font(Theme.Fonts.bakeryBody)
                                    .foregroundColor(.secondary)
                            } else {
                                ForEach(recipe.links, id: \.self) { link in
                                    if let url = URL(string: link) {
                                        Link(destination: url) {
                                            HStack {
                                                Image(systemName: "link")
                                                Text(link)
                                                    .lineLimit(1)
                                                Spacer()
                                                Image(systemName: "arrow.up.right.square")
                                            }
                                            .font(Theme.Fonts.bakeryBody)
                                            .foregroundColor(.flavorlyPink)
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.flavorlyWhite)
                    .cornerRadius(theme.cornerRadius)
                    .shadow(color: .flavorlyPink.opacity(0.2), radius: 8, x: 0, y: 4)
                    
                    // Notes card
                    VStack(alignment: .leading, spacing: 12) {
                        Text("notes")
                            .font(Theme.Fonts.bakeryHeadline)
                            .foregroundColor(.flavorlyPinkDark)
                        
                        if isEditing {
                            TextEditor(text: $editedNotes)
                                .frame(minHeight: 100)
                                .padding(8)
                                .background(Color.white)
                                .cornerRadius(theme.smallCornerRadius)
                        } else {
                            if !recipe.notes.isEmpty {
                                Text(recipe.notes)
                                    .font(.body)
                            } else {
                                Text("No notes")
                                    .font(.body)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.flavorlyWhite)
                    .cornerRadius(theme.cornerRadius)
                    .shadow(color: .flavorlyPink.opacity(0.2), radius: 8, x: 0, y: 4)
                    
                    // Progress Media Section - FOR WHILE COOKING!
                    if recipe.status == .inProgress {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Image(systemName: "camera.fill")
                                    .font(Theme.Fonts.bakeryHeadline)
                                    .foregroundColor(.flavorlyPink)
                                Text("document your progress")
                                    .font(Theme.Fonts.bakeryHeadline)
                                    .foregroundColor(.flavorlyPinkDark)
                            }
                            
                            Button {
                                showingCamera = true
                            } label: {
                                HStack {
                                    Image(systemName: "camera.fill")
                                        .font(.title3)
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("take photo or video")
                                            .font(Theme.Fonts.bakeryBody)
                                            .fontWeight(.semibold)
                                        Text("capture this moment!")
                                            .font(Theme.Fonts.bakeryCaption)
                                    }
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                }
                                .foregroundColor(.white)
                                .padding()
                                .background(
                                    LinearGradient(
                                        colors: [Color.flavorlyPink, Color.flavorlyPinkDark],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .cornerRadius(theme.smallCornerRadius)
                                .shadow(color: .flavorlyPink.opacity(0.4), radius: 8, x: 0, y: 4)
                            }
                            
                            if !recipe.progressMedia.isEmpty {
                                Text("\(recipe.progressMedia.count) moments captured")
                                    .font(Theme.Fonts.bakeryCaption)
                                    .foregroundColor(.flavorlyPink)
                                
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 12) {
                                        ForEach(recipe.progressMedia.prefix(5)) { media in
                                            if let data = Data(base64Encoded: media.data),
                                               let uiImage = UIImage(data: data) {
                                                Image(uiImage: uiImage)
                                                    .resizable()
                                                    .scaledToFill()
                                                    .frame(width: 80, height: 80)
                                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.flavorlyWhite)
                        .cornerRadius(theme.cornerRadius)
                        .shadow(color: .flavorlyPink.opacity(0.2), radius: 8, x: 0, y: 4)
                    }
                    
                    // View Summary Button - FOR COMPLETED RECIPES!
                    if recipe.status == .done && !recipe.progressMedia.isEmpty {
                        Button {
                            showingSummary = true
                        } label: {
                            HStack(spacing: 12) {
                                GIFImage(name: "melody_hearteyes", contentMode: .scaleAspectFit)
                                    .frame(width: 50, height: 50)
                                
                                VStack(alignment: .leading, spacing: 6) {
                                    Text("view journey")
                                        .font(Theme.Fonts.bakeryHeadline)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.flavorlyPinkDark)
                                }
                                
                                Spacer()
                                
                                Image(systemName: "heart.circle.fill")
                                    .font(.title2)
                                    .foregroundColor(.flavorlyPink)
                            }
                            .foregroundColor(.white)
                            .padding()
                            .background(
                                LinearGradient(
                                    colors: [Color.flavorlyRose, Color.flavorlyPink],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(theme.cornerRadius)
                            .shadow(color: .flavorlyRose.opacity(0.4), radius: 8, x: 0, y: 4)
                        }
                        .padding(.horizontal)
                    }
                    
                    // Inspiration Photos Gallery
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("inspiration photos")
                                .font(Theme.Fonts.bakeryHeadline)
                                .foregroundColor(.flavorlyPinkDark)
                            
                            Spacer()
                            
                            if isEditing {
                                Button {
                                    showingImagePicker = true
                                } label: {
                                    HStack(spacing: 4) {
                                        Image(systemName: "plus.circle.fill")
                                        Text("add")
                                            .font(Theme.Fonts.bakeryCaption)
                                    }
                                    .foregroundColor(.flavorlyPink)
                                }
                            }
                        }
                        
                        if editedInspirationPhotos.isEmpty && !isEditing {
                            Text("No photos")
                                .font(.body)
                                .foregroundColor(.secondary)
                        } else {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach(Array(editedInspirationPhotos.enumerated()), id: \.offset) { index, image in
                                        ZStack(alignment: .topTrailing) {
                                            Image(uiImage: image)
                                                .resizable()
                                                .scaledToFill()
                                                .frame(width: 160, height: 160)
                                                .clipShape(RoundedRectangle(cornerRadius: 16))
                                            
                                            if isEditing {
                                                Button {
                                                    editedInspirationPhotos.remove(at: index)
                                                } label: {
                                                    Image(systemName: "xmark.circle.fill")
                                                        .foregroundColor(.red)
                                                        .background(Circle().fill(Color.white))
                                                }
                                                .padding(4)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.flavorlyWhite)
                    .cornerRadius(theme.cornerRadius)
                    .shadow(color: .flavorlyPink.opacity(0.2), radius: 8, x: 0, y: 4)
                    }
                    .padding()
                    .padding(.bottom, 100) // Add bottom padding for tab bar clearance
                }
            }
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker(selectedImages: $newPhotos, limit: 10)
        }
        .onChange(of: newPhotos) { photos in
            // Append new photos to existing ones instead of replacing
            if !photos.isEmpty {
                editedInspirationPhotos.append(contentsOf: photos)
                newPhotos = [] // Clear the temporary array
            }
        }
        .fullScreenCover(isPresented: $showingCamera) {
            CameraView { data, mediaType in
                let base64 = data.base64EncodedString()
                let newMedia = RecipeMedia(type: mediaType, data: base64)
                
                var updatedRecipe = recipe
                updatedRecipe.progressMedia.append(newMedia)
                viewModel.updateRecipe(updatedRecipe)
                recipe = updatedRecipe
            }
        }
            .fullScreenCover(isPresented: $showingSummary) {
                RecipeProgressSummaryView(recipe: recipe)
            }
        .onChange(of: recipe.status) { _, newStatus in
            if newStatus == .done {
                // Show heart particles when recipe is completed
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    // Heart particles will be triggered by the status change
                }
            }
        }
        .heartParticles() // Add heart particles throughout recipe detail
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(isEditing ? "Save" : "Edit") {
                    if isEditing {
                        // Save changes including photos
                        var updatedRecipe = recipe
                        updatedRecipe.name = editedName
                        updatedRecipe.category = editedCategory
                        updatedRecipe.notes = editedNotes
                            updatedRecipe.links = editedLinks
                        updatedRecipe.status = editedStatus
                        updatedRecipe.makeDate = hasDate ? editedMakeDate : nil
                        
                        // Convert UIImages to base64 strings
                        updatedRecipe.inspirationPhotos = editedInspirationPhotos.compactMap { image in
                            image.jpegData(compressionQuality: 0.7)?.base64EncodedString()
                        }
                        
                        viewModel.updateRecipe(updatedRecipe)
                        recipe = updatedRecipe
                    }
                    isEditing.toggle()
                }
                .foregroundColor(.flavorlyPink)
                .fontWeight(.semibold)
            }
        }
    }
}

