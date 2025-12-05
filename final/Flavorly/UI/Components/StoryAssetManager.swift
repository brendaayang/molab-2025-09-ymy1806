//
//  StoryAssetManager.swift
//  Flavorly
//
//  Created by Brenda Yang on 10/18/25.
//

import UIKit
import ImageIO
import MobileCoreServices

class StoryAssetManager {
    static let availableGIFs = [
        "melody_heart",
        "melody_hearteyes",
        "melody_cookie_ok",
        "melody_working",
        "melody_eating2",
        "angry_melody"
    ]
    
    static let availableWallpapers = [
        "wallpaper4", "wallpaper5",
        "wallpaper6", "wallpaper7", "wallpaper8"
    ]
    
    static let availableStaticImages = [
        "melody2", "melody3", "melody4", "melody5"
    ]
    
    static func randomDecoration() -> String {
        let allDecorations = availableGIFs + availableStaticImages
        return allDecorations.randomElement() ?? "melody_heart"
    }
    
    static func randomWallpaper() -> UIImage? {
        let wallpaper = availableWallpapers.randomElement() ?? "wallpaper6"
        return UIImage(named: wallpaper)
    }
    
    static func getFrameFromGIF(name: String, frameIndex: Int = 0) -> UIImage? {
        // First try NSDataAsset for GIFs
        if let asset = NSDataAsset(name: name),
           let imageSource = CGImageSourceCreateWithData(asset.data as CFData, nil) {
            let frameCount = CGImageSourceGetCount(imageSource)
            if frameCount > 0 {
                let index = min(frameIndex, frameCount - 1)
                if let cgImage = CGImageSourceCreateImageAtIndex(imageSource, index, nil) {
                    return UIImage(cgImage: cgImage)
                }
            }
        }
        
        // Try loading from bundle directly
        if let path = Bundle.main.path(forResource: name, ofType: "gif"),
           let data = try? Data(contentsOf: URL(fileURLWithPath: path)),
           let imageSource = CGImageSourceCreateWithData(data as CFData, nil) {
            let frameCount = CGImageSourceGetCount(imageSource)
            if frameCount > 0 {
                let index = min(frameIndex, frameCount - 1)
                if let cgImage = CGImageSourceCreateImageAtIndex(imageSource, index, nil) {
                    return UIImage(cgImage: cgImage)
                }
            }
        }
        
        // Fallback to regular image (for static melody images)
        return UIImage(named: name)
    }
    
    static func getStaticImage(name: String) -> UIImage? {
        return UIImage(named: name)
    }
}

struct DecorativeElement {
    let image: UIImage
    let position: CGPoint
    let size: CGFloat
    let rotation: CGFloat
    let opacity: CGFloat
}

