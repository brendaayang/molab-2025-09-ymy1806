//
//  SettingsView.swift
//  Flavorly
//
//  Created by Brenda Yang on 10/18/25.
//

import SwiftUI
import PhotosUI

struct SettingsView: View {
    @ObservedObject var viewModel: SettingsViewModel
    @ObservedObject var coordinator: AppRootCoordinator
    @EnvironmentObject var theme: Theme
    @State private var showVampireCouple = false
    @State private var showBPDMode = false
    @State private var bpdDestination: String = ""
    @State private var showAddContentOptions = false
    @State private var showPhotosPicker = false
    @State private var showVideosPicker = false
    @State private var showAffirmationEditor = false
    @State private var selectedPhotos: [PhotosPickerItem] = []
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.flavorlyCream.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        GIFImage(name: "melody_many_hearts", contentMode: .scaleAspectFit)
                            .frame(width: 150, height: 150)
                        
                        // Wallpaper settings card
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Image(systemName: "photo.fill")
                                    .foregroundColor(.flavorlyPink)
                                Text("wallpaper")
                                    .font(Theme.Fonts.bakeryHeadline)
                                    .foregroundColor(.flavorlyPinkDark)
                            }
                            
                            Button {
                                viewModel.showingWallpaperPicker = true
                            } label: {
                                HStack {
                                    Image(viewModel.currentWallpaper.rawValue)
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 60, height: 60)
                                        .cornerRadius(theme.smallCornerRadius)
                                        .clipped()
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(viewModel.currentWallpaper.displayName.lowercased())
                                            .font(Theme.Fonts.bakeryBody)
                                            .foregroundColor(.primary)
                                        
                                        Text("tap to change")
                                            .font(Theme.Fonts.bakeryCaption)
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(.flavorlyPink)
                                }
                                .padding()
                                .background(Color.flavorlyPinkLight.opacity(0.3))
                                .cornerRadius(theme.smallCornerRadius)
                            }
                        }
                        .padding()
                        .background(Color.flavorlyWhite)
                        .cornerRadius(theme.cornerRadius)
                        .shadow(color: .flavorlyPink.opacity(0.2), radius: 8, x: 0, y: 4)
                    }
                    .padding()
                    .padding(.bottom, 60) // Extra padding for tab bar clearance
                }
            }
            .navigationTitle("more stuff")
            .heartParticles() // Add heart particles in settings
            .sheet(isPresented: $viewModel.showingWallpaperPicker) {
                WallpaperPickerView(
                    currentWallpaper: viewModel.currentWallpaper,
                    onSelect: { wallpaper in
                        viewModel.selectWallpaper(wallpaper)
                        viewModel.showingWallpaperPicker = false
                    }
                )
            }
            .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("OpenBPDMode"))) { notification in
                if let destination = notification.userInfo?["destination"] as? String {
                    bpdDestination = destination
                    showBPDMode = true
                }
            }
            .photosPicker(isPresented: $showPhotosPicker, selection: $selectedPhotos, maxSelectionCount: 10, matching: .images)
        }
    }
}

struct ContentOptionRow: View {
    let icon: String
    let title: String
    let subtitle: String
    let gradient: [Color]
    @EnvironmentObject var theme: Theme
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: gradient,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 44, height: 44)
                
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(.white)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(Theme.Fonts.bakeryBody)
                    .foregroundColor(.flavorlyPinkDark)
                
                Text(subtitle)
                    .font(Theme.Fonts.bakeryCaption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.flavorlyPink)
        }
        .padding()
        .background(Color.flavorlyWhite)
        .cornerRadius(theme.smallCornerRadius)
        .shadow(color: gradient[0].opacity(0.15), radius: 4, x: 0, y: 2)
    }
}
