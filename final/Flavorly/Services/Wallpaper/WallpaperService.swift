//
//  WallpaperService.swift
//  Flavorly
//
//  Created by Brenda Yang on 10/9/25.
//

import Combine
import Foundation

final class WallpaperService: WallpaperServiceProtocol {
    private let storageService: StorageServiceProtocol
    private let wallpaperKey = "selectedWallpaper"
    
    private let _currentWallpaper: CurrentValueSubject<Wallpaper, Never>
    var currentWallpaper: AnyPublisher<Wallpaper, Never> {
        _currentWallpaper.eraseToAnyPublisher()
    }
    
    init(storageService: StorageServiceProtocol) {
        self.storageService = storageService
        
        // Load saved wallpaper or use default
        let saved: Wallpaper? = storageService.getValue(forKey: wallpaperKey)
        self._currentWallpaper = CurrentValueSubject(saved ?? .wallpaper)
    }
    
    func setWallpaper(_ wallpaper: Wallpaper) {
        storageService.setValue(wallpaper, forKey: wallpaperKey)
        _currentWallpaper.send(wallpaper)
    }
    
    func getCurrentWallpaper() -> Wallpaper {
        _currentWallpaper.value
    }
}

