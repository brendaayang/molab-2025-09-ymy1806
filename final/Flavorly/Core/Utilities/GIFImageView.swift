//
//  GIFImageView.swift
//  Flavorly
//
//  Created by Brenda Yang on 10/18/25.
//

import SwiftUI
import UIKit
import ImageIO

struct GIFImage: UIViewRepresentable {
    let name: String
    let contentMode: UIView.ContentMode
    
    init(name: String, contentMode: UIView.ContentMode = .scaleAspectFit) {
        self.name = name
        self.contentMode = contentMode
    }
    
    func makeUIView(context: Context) -> UIImageView {
        let imageView = UIImageView()
        imageView.contentMode = contentMode
        imageView.clipsToBounds = true
        
        // Configure for SwiftUI layout
        imageView.setContentHuggingPriority(.defaultLow, for: .horizontal)
        imageView.setContentHuggingPriority(.defaultLow, for: .vertical)
        imageView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        imageView.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        
        loadGIF(into: imageView, name: name)
        return imageView
    }
    
    func updateUIView(_ uiView: UIImageView, context: Context) {
        // No updates needed
    }
    
    private func loadGIF(into imageView: UIImageView, name: String) {
        // Try to load from dataset in Assets.xcassets
        guard let asset = NSDataAsset(name: name),
              let source = CGImageSourceCreateWithData(asset.data as CFData, nil) else {
            print("❌ Failed to load GIF: \(name)")
            return
        }
        
        var images = [UIImage]()
        var totalDuration: TimeInterval = 0
        
        let count = CGImageSourceGetCount(source)
        for i in 0..<count {
            if let cgImage = CGImageSourceCreateImageAtIndex(source, i, nil) {
                let image = UIImage(cgImage: cgImage)
                images.append(image)
                
                // Get frame duration
                if let properties = CGImageSourceCopyPropertiesAtIndex(source, i, nil) as? [String: Any],
                   let gifInfo = properties[kCGImagePropertyGIFDictionary as String] as? [String: Any] {
                    let frameDuration = gifInfo[kCGImagePropertyGIFDelayTime as String] as? TimeInterval ?? 0.1
                    totalDuration += frameDuration
                }
            }
        }
        
        imageView.animationImages = images
        imageView.animationDuration = max(totalDuration, 0.1)
        imageView.animationRepeatCount = 0 // Infinite
        imageView.startAnimating()
    }
}

