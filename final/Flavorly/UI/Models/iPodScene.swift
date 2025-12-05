//
//  iPodScene.swift
//  Flavorly
//
//  Created by Brenda Yang on 10/19/25.
//

import Foundation

enum SceneMediaType: Equatable {
    case staticImage(String)
    case animatedGif(String)
    case video(String)
}

enum iPodScene: String, Codable, CaseIterable, Identifiable {
    case retrowaveCity = "retrowave_city"
    case neonGrid = "neon_grid"
    case vaporwaveAesthetic = "vaporwave_aesthetic"
    case cyberCity = "cyber_city"
    case synthwaveSunset = "synthwave_sunset"
    case matrixRain = "matrix_rain"
    case glitchArt = "glitch_art"
    case pixelSpace = "pixel_space"
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .retrowaveCity:
            return "Retrowave City"
        case .neonGrid:
            return "Neon Grid"
        case .vaporwaveAesthetic:
            return "Vaporwave Dreams"
        case .cyberCity:
            return "Cyber Metropolis"
        case .synthwaveSunset:
            return "Synthwave Sunset"
        case .matrixRain:
            return "Matrix Rain"
        case .glitchArt:
            return "Glitch Reality"
        case .pixelSpace:
            return "Pixel Nebula"
        }
    }
    
    var mediaType: SceneMediaType {
        // For now, using static images - can be upgraded to videos/GIFs
        switch self {
        case .retrowaveCity:
            return .staticImage("wallpaper5") // Pink gradient
        case .neonGrid:
            return .staticImage("wallpaper3") // Hearts
        case .vaporwaveAesthetic:
            return .staticImage("wallpaper7") // Rose garden
        case .cyberCity:
            return .staticImage("wallpaper4") // Bubblegum clouds
        case .synthwaveSunset:
            return .staticImage("wallpaper8") // Cherry blossoms
        case .matrixRain:
            return .staticImage("wallpaper6") // Strawberry cream
        case .glitchArt:
            return .staticImage("wallpaper2") // Sweet dreams
        case .pixelSpace:
            return .staticImage("wallpaper") // Pink blossoms
        }
    }
    
    var autoGenre: [MediaCategory]? {
        switch self {
        case .retrowaveCity, .neonGrid:
            return [.classicElectronic, .hyperpop]
        case .vaporwaveAesthetic, .synthwaveSunset:
            return [.slowedReverb, .hyperpop]
        case .cyberCity, .glitchArt:
            return [.hyperpop, .fakemink]
        case .matrixRain:
            return [.classicElectronic, .nightcore]
        case .pixelSpace:
            return [.snowStrippers, .hyperpop]
        }
    }
}

