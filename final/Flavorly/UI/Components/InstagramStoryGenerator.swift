//
//  InstagramStoryGenerator.swift
//  Flavorly
//
//  Created by Brenda Yang on 10/18/25.
//

import SwiftUI
import UIKit

class InstagramStoryGenerator {
    static func generateStory(from media: [RecipeMedia], recipeName: String) -> UIImage? {
        print("📸 InstagramStoryGenerator: Starting generation")
        print("📸 Media count: \(media.count)")
        
        // Instagram Story dimensions: 1080 x 1920 (9:16 aspect ratio)
        let size = CGSize(width: 1080, height: 1920)
        
        UIGraphicsBeginImageContextWithOptions(size, true, 0)
        guard let context = UIGraphicsGetCurrentContext() else {
            print("❌ Failed to create graphics context")
            return nil
        }
        
        print("✅ Graphics context created")
        
        // 1. Draw wallpaper background
        drawWallpaperBackground(in: context, size: size)
        print("✅ Background drawn")
        
        // 2. Arrange photos in aesthetic collage
        let photos = media.compactMap { mediaItem -> UIImage? in
            guard let data = Data(base64Encoded: mediaItem.data) else {
                print("⚠️ Failed to decode base64 data")
                return nil
            }
            return UIImage(data: data)
        }
        
        print("📸 Decoded \(photos.count) photos")
        
        if !photos.isEmpty {
            drawAdvancedCollage(photos: photos, in: context, size: size)
            print("✅ Collage drawn")
        } else {
            print("⚠️ No photos to draw")
        }
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        if let image = image {
            print("✅ Final image created: \(image.size)")
            
            // Verify image has content
            if let cgImage = image.cgImage {
                print("✅ CGImage exists: \(cgImage.width)x\(cgImage.height)")
                print("✅ Color space: \(String(describing: cgImage.colorSpace?.name))")
                print("✅ Bits per component: \(cgImage.bitsPerComponent)")
                print("✅ Bits per pixel: \(cgImage.bitsPerPixel)")
            } else {
                print("⚠️ No CGImage in UIImage")
            }
            
            // Save to disk for verification
            if let data = image.pngData() {
                let path = FileManager.default.temporaryDirectory.appendingPathComponent("test_story.png")
                try? data.write(to: path)
                print("💾 Saved to: \(path.path)")
            }
        } else {
            print("❌ Failed to create final image")
        }
        
        return image
    }
    
    private static func drawWallpaperBackground(in context: CGContext, size: CGSize) {
        print("🎨 Drawing background...")
        
        // First fill with base color
        context.setFillColor(UIColor(red: 1.0, green: 0.95, blue: 0.98, alpha: 1.0).cgColor)
        context.fill(CGRect(origin: .zero, size: size))
        
        // Draw gradient overlay
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let colors = [
            UIColor(red: 1.0, green: 0.90, blue: 0.95, alpha: 1.0).cgColor,
            UIColor(red: 1.0, green: 0.82, blue: 0.90, alpha: 1.0).cgColor
        ]
        
        if let gradient = CGGradient(colorsSpace: colorSpace, colors: colors as CFArray, locations: [0.0, 1.0]) {
            context.drawLinearGradient(gradient,
                                       start: CGPoint(x: 0, y: 0),
                                       end: CGPoint(x: 0, y: size.height),
                                       options: [])
            print("✅ Gradient drawn")
        }
        
        // Try to use wallpaper as overlay
        if let wallpaperImage = StoryAssetManager.randomWallpaper() {
            print("🖼️ Drawing wallpaper overlay")
            context.saveGState()
            wallpaperImage.draw(in: CGRect(origin: .zero, size: size), blendMode: .multiply, alpha: 0.25)
            context.restoreGState()
        }
    }
    
    private static func drawAdvancedCollage(photos: [UIImage], in context: CGContext, size: CGSize) {
        let photoCount = photos.count
        
        // Choose layout based on photo count
        if photoCount == 1 {
            drawSinglePhotoLayout(photo: photos[0], in: context, size: size)
        } else if photoCount == 2 {
            drawTwoPhotoLayout(photos: photos, in: context, size: size)
        } else if photoCount == 3 {
            drawThreePhotoLayout(photos: photos, in: context, size: size)
        } else {
            drawMultiPhotoLayout(photos: photos, in: context, size: size)
        }
    }
    
    private static func drawSinglePhotoLayout(photo: UIImage, in context: CGContext, size: CGSize) {
        // Large centered photo with decorations - BIGGER
        let photoSize = CGSize(width: 900, height: 1000)
        let photoX = (size.width - photoSize.width) / 2
        let photoY = (size.height - photoSize.height) / 2
        
        let photoFrame = CGRect(x: photoX, y: photoY, width: photoSize.width, height: photoSize.height)
        
        // Draw photo with pink frame
        drawPinkPolaroidFrame(photo: photo, frame: photoFrame, rotation: 0, in: context)
        
        // Add corner decorations
        let decorations = placeDecorationsForSinglePhoto(photoFrame: photoFrame, canvasSize: size)
        drawDecorations(decorations, in: context)
    }
    
    private static func drawTwoPhotoLayout(photos: [UIImage], in context: CGContext, size: CGSize) {
        // Stacked diagonally with varied sizes - BIGGER
        let photo1Size = CGSize(width: 800, height: 800)
        let photo2Size = CGSize(width: 750, height: 750)
        
        let frame1 = CGRect(x: 100, y: 350, width: photo1Size.width, height: photo1Size.height)
        let frame2 = CGRect(x: 230, y: 950, width: photo2Size.width, height: photo2Size.height)
        
        drawPinkPolaroidFrame(photo: photos[0], frame: frame1, rotation: -4, in: context)
        drawPinkPolaroidFrame(photo: photos[1], frame: frame2, rotation: 5, in: context)
        
        // Add decorations in negative space
        let decorations = placeDecorationsForTwoPhotos(frame1: frame1, frame2: frame2, canvasSize: size)
        drawDecorations(decorations, in: context)
    }
    
    private static func drawThreePhotoLayout(photos: [UIImage], in context: CGContext, size: CGSize) {
        // Triangle/asymmetric layout - BIGGER
        let sizes = [
            CGSize(width: 700, height: 700),
            CGSize(width: 680, height: 680),
            CGSize(width: 720, height: 720)
        ]
        
        let frames = [
            CGRect(x: 100, y: 220, width: sizes[0].width, height: sizes[0].height),
            CGRect(x: 380, y: 720, width: sizes[1].width, height: sizes[1].height),
            CGRect(x: 90, y: 1150, width: sizes[2].width, height: sizes[2].height)
        ]
        
        let rotations: [CGFloat] = [-5, 6, -3]
        
        for (index, photo) in photos.enumerated() {
            drawPinkPolaroidFrame(photo: photo, frame: frames[index], rotation: rotations[index], in: context)
        }
        
        // Add decorations strategically
        let decorations = placeDecorationsForThreePhotos(frames: frames, canvasSize: size)
        drawDecorations(decorations, in: context)
    }
    
    private static func drawMultiPhotoLayout(photos: [UIImage], in context: CGContext, size: CGSize) {
        // Asymmetric grid - BIGGER
        let photoSize = CGSize(width: 600, height: 600)
        
        let layouts: [(x: CGFloat, y: CGFloat, rotation: CGFloat)] = [
            (80, 250, -3),
            (520, 280, 4),
            (60, 880, 2),
            (500, 920, -4),
            (280, 1350, 3),
            (60, 1380, -2)
        ]
        
        for (index, photo) in photos.prefix(6).enumerated() {
            let layout = layouts[index]
            let frame = CGRect(x: layout.x, y: layout.y, width: photoSize.width, height: photoSize.height)
            drawPinkPolaroidFrame(photo: photo, frame: frame, rotation: layout.rotation, in: context)
        }
        
        // Add decorations throughout
        let decorations = placeDecorationsForMultiPhotos(count: min(photos.count, 6), canvasSize: size)
        drawDecorations(decorations, in: context)
    }
    
    private static func drawPinkPolaroidFrame(photo: UIImage, frame: CGRect, rotation: CGFloat, in context: CGContext) {
        print("🖼️ Drawing polaroid at \(frame.origin)")
        
        context.saveGState()
        
        // Translate to center of frame
        context.translateBy(x: frame.midX, y: frame.midY)
        context.rotate(by: rotation * .pi / 180)
        context.translateBy(x: -frame.width / 2, y: -frame.height / 2)
        
        // Draw outer shadow
        context.setShadow(offset: CGSize(width: 0, height: 20), blur: 35, color: UIColor.black.withAlphaComponent(0.25).cgColor)
        
        // Draw pink frame background
        let borderSize: CGFloat = 35
        let bottomBorder: CGFloat = 70
        
        let frameRect = CGRect(x: 0, y: 0, width: frame.width, height: frame.height)
        let framePath = UIBezierPath(roundedRect: frameRect, cornerRadius: 15)
        
        // Fill with VIBRANT pink gradient
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let frameColors = [
            UIColor(red: 1.0, green: 0.80, blue: 0.88, alpha: 1.0).cgColor,  // Vibrant light pink
            UIColor(red: 1.0, green: 0.65, blue: 0.80, alpha: 1.0).cgColor   // Vibrant darker pink
        ]
        
        guard let frameGradient = CGGradient(colorsSpace: colorSpace, colors: frameColors as CFArray, locations: [0.0, 1.0]) else {
            context.setFillColor(UIColor(red: 1.0, green: 0.85, blue: 0.90, alpha: 1.0).cgColor)
            framePath.fill()
            print("⚠️ Using fallback pink color")
            context.restoreGState()
            return
        }
        
        context.saveGState()
        framePath.addClip()
        context.drawLinearGradient(frameGradient,
                                   start: CGPoint(x: 0, y: 0),
                                   end: CGPoint(x: 0, y: frame.height),
                                   options: [])
        context.restoreGState()
        
        print("✅ Pink frame drawn")
        
        // Draw photo inside frame with rounded corners
        let photoRect = CGRect(x: borderSize,
                              y: borderSize,
                              width: frame.width - borderSize * 2,
                              height: frame.height - borderSize - bottomBorder)
        
        context.saveGState()
        context.setShadow(offset: .zero, blur: 0, color: nil) // Clear shadow for photo
        let photoPath = UIBezierPath(roundedRect: photoRect, cornerRadius: 10)
        photoPath.addClip()
        photo.draw(in: photoRect, blendMode: .normal, alpha: 1.0)
        context.restoreGState()
        
        print("✅ Photo drawn")
        
        context.restoreGState()
    }
    
    // Smart decoration placement algorithms
    
    private static func placeDecorationsForSinglePhoto(photoFrame: CGRect, canvasSize: CGSize) -> [DecorativeElement] {
        var decorations: [DecorativeElement] = []
        
        // Corner decorations - try each one individually
        let corners: [(CGPoint, CGFloat, String)] = [
            (CGPoint(x: 180, y: 150), -15, "melody_heart"),
            (CGPoint(x: canvasSize.width - 180, y: 170), 20, "melody_hearteyes"),
            (CGPoint(x: 150, y: canvasSize.height - 250), 15, "melody_cookie_ok"),
            (CGPoint(x: canvasSize.width - 160, y: canvasSize.height - 220), -10, "melody_working"),
            (CGPoint(x: canvasSize.width / 2, y: 120), 8, "melody2"),
            (CGPoint(x: 150, y: canvasSize.height / 2), -12, "melody3")
        ]
        
        for corner in corners {
            // Try GIF first, then static images
            if let image = StoryAssetManager.getFrameFromGIF(name: corner.2) {
                decorations.append(DecorativeElement(
                    image: image,
                    position: corner.0,
                    size: CGFloat.random(in: 180...240),
                    rotation: corner.1,
                    opacity: 0.92
                ))
            } else if let image = UIImage(named: corner.2) {
                decorations.append(DecorativeElement(
                    image: image,
                    position: corner.0,
                    size: CGFloat.random(in: 180...240),
                    rotation: corner.1,
                    opacity: 0.92
                ))
            }
        }
        
        // Add larger scattered elements
        addScatteredDecorations(&decorations, avoiding: [photoFrame], canvasSize: canvasSize, count: 4)
        
        return decorations
    }
    
    private static func placeDecorationsForTwoPhotos(frame1: CGRect, frame2: CGRect, canvasSize: CGSize) -> [DecorativeElement] {
        var decorations: [DecorativeElement] = []
        
        // Between photos - MUCH BIGGER
        let betweenPoint = CGPoint(x: (frame1.maxX + frame2.minX) / 2, y: (frame1.maxY + frame2.minY) / 2)
        if let image = StoryAssetManager.getFrameFromGIF(name: "melody_heart") {
            decorations.append(DecorativeElement(
                image: image,
                position: betweenPoint,
                size: 220,
                rotation: 0,
                opacity: 0.95
            ))
        }
        
        // Corners - MUCH BIGGER
        let positions: [(CGPoint, String, CGFloat)] = [
            (CGPoint(x: 180, y: 200), "melody_hearteyes", -10),
            (CGPoint(x: canvasSize.width - 180, y: 1700), "melody_cookie_ok", 15),
            (CGPoint(x: 180, y: canvasSize.height - 250), "melody_working", -8),
            (CGPoint(x: canvasSize.width - 180, y: 350), "melody2", 12),
            (CGPoint(x: 180, y: 1200), "melody_eating2", -12),
            (CGPoint(x: canvasSize.width / 2, y: 150), "melody4", 8)
        ]
        
        for pos in positions {
            if let image = StoryAssetManager.getFrameFromGIF(name: pos.1) {
                decorations.append(DecorativeElement(
                    image: image,
                    position: pos.0,
                    size: CGFloat.random(in: 170...220),
                    rotation: pos.2,
                    opacity: 0.92
                ))
            } else if let image = UIImage(named: pos.1) {
                decorations.append(DecorativeElement(
                    image: image,
                    position: pos.0,
                    size: CGFloat.random(in: 170...220),
                    rotation: pos.2,
                    opacity: 0.92
                ))
            }
        }
        
        return decorations
    }
    
    private static func placeDecorationsForThreePhotos(frames: [CGRect], canvasSize: CGSize) -> [DecorativeElement] {
        var decorations: [DecorativeElement] = []
        
        // Strategic placement between photos - MUCH BIGGER
        let positions: [(CGPoint, String, CGFloat, CGFloat)] = [
            (CGPoint(x: 800, y: 450), "melody_heart", 190, 5),
            (CGPoint(x: 160, y: 950), "melody_hearteyes", 180, -10),
            (CGPoint(x: 820, y: 1350), "melody_cookie_ok", 200, 12),
            (CGPoint(x: 140, y: 150), "melody_working", 170, -8),
            (CGPoint(x: canvasSize.width - 160, y: 200), "angry_melody", 180, 15),
            (CGPoint(x: canvasSize.width / 2, y: 100), "melody2", 170, -5),
            (CGPoint(x: 150, y: 700), "melody3", 160, 10),
            (CGPoint(x: canvasSize.width - 170, y: 1600), "melody_eating2", 175, -12)
        ]
        
        for pos in positions {
            if let image = StoryAssetManager.getFrameFromGIF(name: pos.1) {
                decorations.append(DecorativeElement(
                    image: image,
                    position: pos.0,
                    size: pos.2,
                    rotation: pos.3,
                    opacity: 0.92
                ))
            } else if let image = UIImage(named: pos.1) {
                decorations.append(DecorativeElement(
                    image: image,
                    position: pos.0,
                    size: pos.2,
                    rotation: pos.3,
                    opacity: 0.92
                ))
            }
        }
        
        return decorations
    }
    
    private static func placeDecorationsForMultiPhotos(count: Int, canvasSize: CGSize) -> [DecorativeElement] {
        var decorations: [DecorativeElement] = []
        
        // Prominent decorations even for busy layouts - MUCH BIGGER
        let positions: [(CGPoint, CGFloat)] = [
            (CGPoint(x: 540, y: 150), 150),
            (CGPoint(x: 140, y: 620), 140),
            (CGPoint(x: 900, y: 700), 160),
            (CGPoint(x: 230, y: 1220), 145),
            (CGPoint(x: 820, y: 1670), 155),
            (CGPoint(x: canvasSize.width / 2, y: 450), 140),
            (CGPoint(x: 170, y: 1450), 135)
        ]
        
        for (index, pos) in positions.prefix(min(7, count + 2)).enumerated() {
            let gifName = StoryAssetManager.availableGIFs[index % StoryAssetManager.availableGIFs.count]
            if let image = StoryAssetManager.getFrameFromGIF(name: gifName) {
                decorations.append(DecorativeElement(
                    image: image,
                    position: pos.0,
                    size: pos.1,
                    rotation: CGFloat.random(in: -18...18),
                    opacity: 0.9
                ))
            } else if let staticImage = UIImage(named: "melody\(index + 2)") {
                decorations.append(DecorativeElement(
                    image: staticImage,
                    position: pos.0,
                    size: pos.1,
                    rotation: CGFloat.random(in: -18...18),
                    opacity: 0.9
                ))
            }
        }
        
        return decorations
    }
    
    private static func addScatteredDecorations(_ decorations: inout [DecorativeElement], avoiding frames: [CGRect], canvasSize: CGSize, count: Int) {
        for _ in 0..<count {
            let randomX = CGFloat.random(in: 100...(canvasSize.width - 100))
            let randomY = CGFloat.random(in: 150...(canvasSize.height - 150))
            let position = CGPoint(x: randomX, y: randomY)
            
            // Check if position overlaps with photos
            var overlaps = false
            for frame in frames {
                let expandedFrame = frame.insetBy(dx: -100, dy: -100)
                if expandedFrame.contains(position) {
                    overlaps = true
                    break
                }
            }
            
            if !overlaps, let image = StoryAssetManager.getFrameFromGIF(name: StoryAssetManager.randomDecoration()) {
                decorations.append(DecorativeElement(
                    image: image,
                    position: position,
                    size: CGFloat.random(in: 140...190),
                    rotation: CGFloat.random(in: -20...20),
                    opacity: CGFloat.random(in: 0.85...0.95)
                ))
            }
        }
    }
    
    private static func drawDecorations(_ decorations: [DecorativeElement], in context: CGContext) {
        for decoration in decorations {
            context.saveGState()
            
            // Translate and rotate
            context.translateBy(x: decoration.position.x, y: decoration.position.y)
            context.rotate(by: decoration.rotation * .pi / 180)
            context.setAlpha(decoration.opacity)
            
            let rect = CGRect(x: -decoration.size / 2,
                            y: -decoration.size / 2,
                            width: decoration.size,
                            height: decoration.size)
            
            decoration.image.draw(in: rect)
            
            context.restoreGState()
        }
    }
}
