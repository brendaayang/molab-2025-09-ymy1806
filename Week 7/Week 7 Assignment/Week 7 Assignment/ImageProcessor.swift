import UIKit
import CoreImage
import CoreImage.CIFilterBuiltins

@MainActor
enum ImageProcessor {
    private static let context = CIContext()

    /// Process image applying rotation, crop, color controls, and sepia.
    static func process(image: UIImage,
                        brightness: Float,
                        contrast: Float,
                        sepia: Bool,
                        rotationSteps: Int,
                        cropSquare: Bool) async -> UIImage? {
        // 1) Start with transform operations on UIImage (rotation + crop) so orientation and pixel dimensions are correct for CI
        var working = image

        // Rotation
        if rotationSteps % 4 != 0 {
            let angle = CGFloat(rotationSteps) * .pi/2
            if let rotated = working.rotated(by: angle) {
                working = rotated
            }
        }

        // Crop center square if requested
        if cropSquare, let cropped = working.croppedToCenterSquare() {
            working = cropped
        }

        // 2) Feed to Core Image for color adjustments
        guard let ciInput = CIImage(image: working) else { return working }

        // Color controls
        let colorControls = CIFilter.colorControls()
        colorControls.inputImage = ciInput
        colorControls.brightness = brightness
        colorControls.contrast = contrast

        // Chain filter outputs
        var outputImage = colorControls.outputImage

        if sepia {
            let sepiaFilter = CIFilter.sepiaTone()
            sepiaFilter.inputImage = outputImage
            sepiaFilter.intensity = 0.8
            outputImage = sepiaFilter.outputImage
        }

        // Render CI to UIImage
        if let output = outputImage,
           let cgImage = context.createCGImage(output, from: output.extent) {
            return UIImage(cgImage: cgImage, scale: working.scale, orientation: .up)
        }

        return working
    }
}

// MARK: - UIImage helpers
fileprivate extension UIImage {
    func rotated(by radians: CGFloat) -> UIImage? {
        let newSize = CGRect(origin: .zero, size: size).applying(CGAffineTransform(rotationAngle: radians)).integral.size
        UIGraphicsBeginImageContextWithOptions(newSize, false, scale)
        guard let ctx = UIGraphicsGetCurrentContext() else { return nil }
        ctx.translateBy(x: newSize.width/2, y: newSize.height/2)
        ctx.rotate(by: radians)
        draw(in: CGRect(x: -size.width/2, y: -size.height/2, width: size.width, height: size.height))
        let rotated = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return rotated
    }

    func croppedToCenterSquare() -> UIImage? {
        let imgSize = size
        let length = min(imgSize.width, imgSize.height)
        let originX = (imgSize.width - length) / 2.0
        let originY = (imgSize.height - length) / 2.0
        let cropRect = CGRect(x: originX * scale, y: originY * scale, width: length * scale, height: length * scale)

        guard let cg = cgImage?.cropping(to: cropRect) else { return nil }
        return UIImage(cgImage: cg, scale: scale, orientation: imageOrientation)
    }

    /// Fix orientation if camera asset or other orientation metadata exists.
    func fixOrientation() -> UIImage {
        if imageOrientation == .up { return self }
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        draw(in: CGRect(origin: .zero, size: size))
        let normalized = UIGraphicsGetImageFromCurrentImageContext() ?? self
        UIGraphicsEndImageContext()
        return normalized
    }
}
