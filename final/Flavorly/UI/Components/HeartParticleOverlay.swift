//
//  HeartParticleOverlay.swift
//  Flavorly
//
//  Created by Brenda Yang on 10/18/25.
//

import SwiftUI

struct HeartParticleOverlay: View {
    @State private var isAnimating = false
    @State private var hearts: [HeartData] = []
    
    var body: some View {
        ZStack {
            ForEach(hearts, id: \.id) { heart in
                Image(systemName: "heart.fill")
                    .font(.system(size: heart.size))
                    .foregroundColor(heart.color)
                    .offset(
                        x: isAnimating ? heart.finalX : heart.startX,
                        y: isAnimating ? heart.finalY : heart.startY
                    )
                    .opacity(isAnimating ? 0 : 1)
                    .rotationEffect(.degrees(isAnimating ? heart.rotation : 0))
                    .animation(
                        Animation.easeOut(duration: heart.duration)
                            .delay(heart.delay),
                        value: isAnimating
                    )
            }
        }
        .onAppear {
            generateHearts()
            startAnimation()
        }
    }
    
    private func generateHearts() {
        hearts = (0..<15).map { _ in
            HeartData(
                size: CGFloat.random(in: 8...20),
                color: [Color.flavorlyPink, Color.flavorlyRose, Color.flavorlyPinkLight].randomElement() ?? .flavorlyPink,
                startX: CGFloat.random(in: -50...50),
                startY: CGFloat.random(in: -50...50),
                finalX: CGFloat.random(in: -200...200),
                finalY: CGFloat.random(in: -300...(-100)),
                rotation: Double.random(in: 0...720),
                duration: Double.random(in: 2...4),
                delay: Double.random(in: 0...1)
            )
        }
    }
    
    private func startAnimation() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            isAnimating = true
        }
    }
}

struct HeartData {
    let id = UUID()
    let size: CGFloat
    let color: Color
    let startX: CGFloat
    let startY: CGFloat
    let finalX: CGFloat
    let finalY: CGFloat
    let rotation: Double
    let duration: Double
    let delay: Double
}

// View modifier for easy application
struct HeartParticleModifier: ViewModifier {
    @State private var showHearts = false
    
    func body(content: Content) -> some View {
        ZStack {
            content
            
            if showHearts {
                HeartParticleOverlay()
                    .allowsHitTesting(false)
            }
        }
        .onAppear {
            showHearts = true
            // Hide after animation completes
            DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                showHearts = false
            }
        }
    }
}

extension View {
    func heartParticles() -> some View {
        modifier(HeartParticleModifier())
    }
}
