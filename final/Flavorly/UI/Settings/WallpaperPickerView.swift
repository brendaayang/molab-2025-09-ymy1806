//
//  WallpaperPickerView.swift
//  Flavorly
//
//  Created by Brenda Yang on 10/18/25.
//

import SwiftUI

struct WallpaperPickerView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var theme: Theme
    
    let currentWallpaper: Wallpaper
    let onSelect: (Wallpaper) -> Void
    
    let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    // Randomize wallpaper order on init
    @State private var wallpapers: [Wallpaper] = Wallpaper.allCases.shuffled()
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.flavorlyCream.ignoresSafeArea()
                
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(wallpapers, id: \.self) { wallpaper in
                            Button {
                                onSelect(wallpaper)
                            } label: {
                                VStack(spacing: 12) {
                                    ZStack {
                                        Image(wallpaper.rawValue)
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(width: 160, height: 200)
                                            .cornerRadius(theme.cornerRadius)
                                            .clipped()
                                        
                                        if wallpaper == currentWallpaper {
                                            RoundedRectangle(cornerRadius: theme.cornerRadius)
                                                .strokeBorder(Color.flavorlyPink, lineWidth: 4)
                                            
                                            VStack {
                                                Spacer()
                                                HStack {
                                                    Spacer()
                                                    Image(systemName: "checkmark.circle.fill")
                                                        .font(.title)
                                                        .foregroundColor(.flavorlyPink)
                                                        .background(
                                                            Circle()
                                                                .fill(Color.white)
                                                                .padding(4)
                                                        )
                                                        .padding(8)
                                                }
                                            }
                                        }
                                    }
                                    
                                    Text(wallpaper.displayName.lowercased())
                                        .font(Theme.Fonts.bakeryBody)
                                        .foregroundColor(.flavorlyPinkDark)
                                }
                                .background(Color.flavorlyWhite)
                                .cornerRadius(theme.cornerRadius)
                                .shadow(color: .flavorlyPink.opacity(0.2), radius: 8, x: 0, y: 4)
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("choose wallpaper")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("done") {
                        dismiss()
                    }
                    .font(Theme.Fonts.bakeryBody)
                    .foregroundColor(.flavorlyPink)
                }
            }
        }
    }
}

