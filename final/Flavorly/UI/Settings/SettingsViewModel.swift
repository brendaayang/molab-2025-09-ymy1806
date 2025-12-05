//
//  SettingsViewModel.swift
//  Flavorly
//
//  Created by Brenda Yang on 10/18/25.
//

import SwiftUI
import Combine

final class SettingsViewModel: Bindable, ViewModel {
    let id = UUID()
    
    private let wallpaperService: WallpaperServiceProtocol
    
    @Published var currentWallpaper: Wallpaper = .wallpaper
    @Published var showingWallpaperPicker = false
    
    init(wallpaperService: WallpaperServiceProtocol) {
        self.wallpaperService = wallpaperService
        super.init()
        
        bind()
        
        // Subscribe to wallpaper changes
        wallpaperService.currentWallpaper
            .receive(on: DispatchQueue.main)
            .assign(to: &$currentWallpaper)
    }
    
    func selectWallpaper(_ wallpaper: Wallpaper) {
        wallpaperService.setWallpaper(wallpaper)
    }
}

