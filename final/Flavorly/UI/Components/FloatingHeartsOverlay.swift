import SwiftUI

struct FloatingHeartsOverlay: View {
    @State private var hearts: [FloatingHeartData] = []
    
    var body: some View {
        ZStack {
            ForEach(hearts) { heart in
                Image(systemName: "heart.fill")
                    .font(.system(size: heart.size))
                    .foregroundColor(heart.color.opacity(heart.opacity))
                    .offset(x: heart.offsetX, y: heart.offsetY)
                    .rotationEffect(.degrees(heart.rotation))
            }
        }
        .onAppear {
            generateHearts()
            animateHearts()
        }
    }
    
    private func generateHearts() {
        hearts = (0..<12).map { _ in
            FloatingHeartData(
                size: CGFloat.random(in: 20...40),
                color: [Color.flavorlyPink, Color.flavorlyRose, Color.flavorlyPinkLight].randomElement()!,
                offsetX: CGFloat.random(in: -150...150),
                offsetY: CGFloat.random(in: -300...300),
                rotation: Double.random(in: -15...15),
                opacity: Double.random(in: 0.15...0.35)
            )
        }
    }
    
    private func animateHearts() {
        for i in hearts.indices {
            let duration = Double.random(in: 5...10)
            let delay = Double.random(in: 0...2)
            
            withAnimation(
                Animation.easeInOut(duration: duration)
                    .repeatForever(autoreverses: true)
                    .delay(delay)
            ) {
                hearts[i].offsetY += CGFloat.random(in: -80...80)
                hearts[i].offsetX += CGFloat.random(in: -40...40)
                hearts[i].rotation += Double.random(in: -10...10)
            }
        }
    }
}

struct FloatingHeartData: Identifiable {
    let id = UUID()
    var size: CGFloat
    var color: Color
    var offsetX: CGFloat
    var offsetY: CGFloat
    var rotation: Double
    var opacity: Double
}

