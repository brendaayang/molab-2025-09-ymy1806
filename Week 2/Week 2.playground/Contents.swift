import UIKit
import PlaygroundSupport

func render10Print(size: CGSize = CGSize(width: 1024, height: 1024),
                   cell: CGFloat = 32,
                   lineWidth: CGFloat = 6,
                   bg: UIColor = .black,
                   fg: UIColor = .white) -> UIImage {
    UIGraphicsImageRenderer(size: size).image { ctx in
        let cg = ctx.cgContext
        
        // Background
        cg.setFillColor(bg.cgColor)
        cg.fill(CGRect(origin: .zero, size: size))
        
        // Pattern
        cg.setStrokeColor(fg.cgColor)
        cg.setLineWidth(lineWidth)
        cg.setLineCap(.square)
        
        let cols = Int(size.width / cell)
        let rows = Int(size.height / cell)
        
        for r in 0..<rows {
            for c in 0..<cols {
                let x = CGFloat(c) * cell
                let y = CGFloat(r) * cell
                if Bool.random() {
                    cg.move(to: CGPoint(x: x, y: y))
                    cg.addLine(to: CGPoint(x: x + cell, y: y + cell))
                } else {
                    cg.move(to: CGPoint(x: x + cell, y: y))
                    cg.addLine(to: CGPoint(x: x, y: y + cell))
                }
                cg.strokePath()
            }
        }
    }
}

func savePNG(_ image: UIImage, named name: String) -> URL? {
    let url = playgroundSharedDataDirectory.appendingPathComponent("\(name).png")
    guard let data = image.pngData() else { return nil }
    do {
        try data.write(to: url, options: .atomic)
        return url
    } catch {
        print("Save failed:", error)
        return nil
    }
}

// Render + save
let img = render10Print()
if let url = savePNG(img, named: "10print-1024") {
    print("Saved:", url.path)
}

// Show live
let iv = UIImageView(image: img)
iv.contentMode = .scaleAspectFit
iv.frame = CGRect(x: 0, y: 0, width: 512, height: 512)
PlaygroundPage.current.liveView = iv
