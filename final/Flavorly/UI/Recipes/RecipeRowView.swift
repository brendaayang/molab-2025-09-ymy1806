//
//  RecipeRowView.swift
//  Flavorly
//
//  Created by Brenda Yang on 9/19/25.
//

import SwiftUI

struct RecipeRowView: View {
    let recipe: Recipe
    @EnvironmentObject var theme: Theme
    
    var body: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                Text(recipe.name.lowercased())
                    .font(Theme.Fonts.bakeryHeadline)
                    .fontWeight(.bold)
                    .foregroundColor(.flavorlyPinkDark)
                
                if !recipe.category.isEmpty {
                    Text(recipe.category.lowercased())
                        .font(Theme.Fonts.bakeryCaption)
                        .foregroundColor(.secondary)
                }
                
                HStack(spacing: 10) {
                    // Status capsule
                    HStack(spacing: 6) {
                        Image(systemName: recipe.status.icon)
                            .font(.caption)
                        Text(recipe.status.rawValue.lowercased())
                            .font(Theme.Fonts.bakeryCaption)
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .fill(recipe.status.color)
                            .shadow(color: recipe.status.color.opacity(0.4), radius: 4, y: 2)
                    )
                    
                    if let makeDate = recipe.makeDate {
                        HStack(spacing: 4) {
                            Image(systemName: "calendar")
                                .font(.caption2)
                            Text(makeDate, style: .date)
                                .font(.caption)
                        }
                        .foregroundColor(.secondary)
                    }
                }
            }
            
            Spacer()
            
            // Inspiration photos thumbnail (if available) - moved to right side
            if !recipe.inspirationPhotos.isEmpty {
                stackedPhotosView
            }
        }
        .padding(16)
        .background(Color.flavorlyWhite)
        .cornerRadius(theme.cornerRadius)
        .shadow(color: .flavorlyPink.opacity(0.15), radius: 8, x: 0, y: 4)
    }
    
    @ViewBuilder
    private var stackedPhotosView: some View {
        ZStack {
            let photoCount = min(recipe.inspirationPhotos.count, 3)
            
            if photoCount == 1 {
                // Single photo - slightly tilted
                if let imageData = Data(base64Encoded: recipe.inspirationPhotos[0]),
                   let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 60, height: 60)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.flavorlyPink, lineWidth: 2.5)
                        )
                        .rotationEffect(.degrees(-8))
                        .shadow(color: .flavorlyPink.opacity(0.3), radius: 4, x: 2, y: 2)
                }
            } else if photoCount == 2 {
                // Two photos - overlapping with different tilts
                ForEach(0..<2, id: \.self) { index in
                    if let imageData = Data(base64Encoded: recipe.inspirationPhotos[index]),
                       let uiImage = UIImage(data: imageData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 55, height: 55)
                            .clipShape(RoundedRectangle(cornerRadius: 11))
                            .overlay(
                                RoundedRectangle(cornerRadius: 11)
                                    .stroke(Color.flavorlyPink, lineWidth: 2.5)
                            )
                            .rotationEffect(.degrees(index == 0 ? -12 : 8))
                            .offset(x: CGFloat(index) * 10, y: CGFloat(index) * -4)
                            .zIndex(Double(2 - index))
                            .shadow(color: .flavorlyPink.opacity(0.25), radius: 3, x: 1, y: 1)
                    }
                }
            } else {
                // Three photos - cute fan layout
                ForEach(0..<3, id: \.self) { index in
                    if let imageData = Data(base64Encoded: recipe.inspirationPhotos[index]),
                       let uiImage = UIImage(data: imageData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 50, height: 50)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.flavorlyPink, lineWidth: 2.5)
                            )
                            .rotationEffect(.degrees(index == 0 ? -15 : index == 1 ? 0 : 12))
                            .offset(
                                x: CGFloat(index - 1) * 8,
                                y: CGFloat(index) * -3
                            )
                            .zIndex(Double(3 - index))
                            .shadow(color: .flavorlyPink.opacity(0.2), radius: 2, x: 1, y: 1)
                    }
                }
            }
        }
        .frame(width: 75, height: 65)
    }
}

