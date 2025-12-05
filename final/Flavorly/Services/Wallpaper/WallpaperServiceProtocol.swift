//
//  WallpaperServiceProtocol.swift
//  Flavorly
//
//  Created by Brenda Yang on 10/9/25.
//

import Combine

protocol WallpaperServiceProtocol {
    var currentWallpaper: AnyPublisher<Wallpaper, Never> { get }
    func setWallpaper(_ wallpaper: Wallpaper)
    func getCurrentWallpaper() -> Wallpaper
}

