//
//  AddRecipeView.swift
//  Flavorly
//
//  Created by Brenda Yang on 10/18/25.
//

import SwiftUI

struct AddRecipeView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var theme: Theme
    
    @State private var name = ""
    @State private var category = ""
    @State private var notes = ""
    @State private var links: [String] = [""]
    @State private var status: RecipeStatus = .planning
    @State private var makeDate: Date?
    @State private var hasDate = false
    @State private var selectedImages: [UIImage] = []
    @State private var showingImagePicker = false
    
    let onSave: (String, String, Date?, String, [String], RecipeStatus, [String]) -> Void
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.flavorlyCream.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Cute header with My Melody
                        GIFImage(name: "melody_hearteyes", contentMode: .scaleAspectFit)
                            .frame(width: 100, height: 100)
                            .padding(.top)
                        
                        Text("let's baking something")
                            .font(Theme.Fonts.bakeryTitle3)
                            .foregroundColor(.flavorlyPinkDark)
                            .padding(.top, 16) // Add padding above text
                        

                        // Name field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("recipe name")
                                .font(Theme.Fonts.bakeryHeadline)
                                .foregroundColor(.flavorlyPinkDark)
                            
                            TextField("e.g., Strawberry Cupcakes", text: $name)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .font(Theme.Fonts.bakeryBody)
                        }
                        
                        // Category field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("category")
                                .font(Theme.Fonts.bakeryHeadline)
                                .foregroundColor(.flavorlyPinkDark)
                            
                            TextField("e.g., Desserts", text: $category)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .font(Theme.Fonts.bakeryBody)
                        }
                        
                        // Status picker
                        VStack(alignment: .leading, spacing: 8) {
                            Text("status")
                                .font(Theme.Fonts.bakeryHeadline)
                                .foregroundColor(.flavorlyPinkDark)
                            
                            CustomStatusSelector(selectedStatus: $status) { _ in
                                // Status changed
                            }
                        }
                        
                        // Date toggle and picker
                        VStack(alignment: .leading, spacing: 8) {
                            Toggle("set make date", isOn: $hasDate)
                                .font(Theme.Fonts.bakeryHeadline)
                                .foregroundColor(.flavorlyPinkDark)
                            
                            if hasDate {
                                DatePicker(
                                    "make date",
                                    selection: Binding(
                                        get: { makeDate ?? Date() },
                                        set: { makeDate = $0 }
                                    ),
                                    displayedComponents: .date
                                )
                                .datePickerStyle(GraphicalDatePickerStyle())
                                .accentColor(.flavorlyPink)
                                .font(Theme.Fonts.bakeryBody)
                            }
                        }
                        
                        // Link field
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("recipe links")
                                    .font(Theme.Fonts.bakeryHeadline)
                                    .foregroundColor(.flavorlyPinkDark)
                                
                                Spacer()
                                
                                Button {
                                    links.append("")
                                } label: {
                                    Image(systemName: "plus.circle.fill")
                                        .foregroundColor(.flavorlyPink)
                                }
                            }
                            
                            ForEach(links.indices, id: \.self) { index in
                                HStack {
                                    TextField("https://...", text: $links[index])
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                        .autocapitalization(.none)
                                        .keyboardType(.URL)
                                    
                                    if links.count > 1 {
                                        Button {
                                            links.remove(at: index)
                                        } label: {
                                            Image(systemName: "minus.circle.fill")
                                                .foregroundColor(.red)
                                        }
                                    }
                                }
                            }
                        }
                        
                        // Notes field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("notes")
                                .font(Theme.Fonts.bakeryHeadline)
                                .foregroundColor(.flavorlyPinkDark)
                            
                            TextEditor(text: $notes)
                                .font(Theme.Fonts.bakeryBody)
                                .frame(height: 100)
                                .padding(8)
                                .background(Color.white)
                                .cornerRadius(theme.smallCornerRadius)
                                .overlay(
                                    RoundedRectangle(cornerRadius: theme.smallCornerRadius)
                                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                                )
                        }
                        
                        // Inspiration Photos
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("inspiration photos")
                                    .font(Theme.Fonts.bakeryHeadline)
                                    .foregroundColor(.flavorlyPinkDark)
                                Spacer()
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

                            if selectedImages.isEmpty {
                                Text("no photos selected")
                                    .font(Theme.Fonts.bakeryBody)
                                    .foregroundColor(.secondary)
                            } else {
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 10) {
                                        ForEach(Array(selectedImages.enumerated()), id: \.offset) { index, image in
                                            ZStack(alignment: .topTrailing) {
                                                Image(uiImage: image)
                                                    .resizable()
                                                    .scaledToFill()
                                                    .frame(width: 100, height: 100)
                                                    .clipShape(RoundedRectangle(cornerRadius: 10))

                                                Button {
                                                    selectedImages.remove(at: index)
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
                }
            }
            .navigationTitle("new recipe")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showingImagePicker) {
                ImagePicker(selectedImages: $selectedImages, limit: 10)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("cancel") {
                        dismiss()
                    }
                    .font(Theme.Fonts.bakeryBody)
                    .foregroundColor(.flavorlyPink)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("save") {
                        let base64Photos = selectedImages.compactMap { image in
                            image.jpegData(compressionQuality: 0.7)?.base64EncodedString()
                        }
                        onSave(name, category, hasDate ? makeDate : nil, notes, links, status, base64Photos)
                    }
                    .font(Theme.Fonts.bakeryBody)
                    .foregroundColor(.flavorlyPink)
                    .fontWeight(.semibold)
                    .disabled(name.isEmpty)
                }
            }
        }
        .heartParticles() // Add heart particles when creating recipes
    }
}

