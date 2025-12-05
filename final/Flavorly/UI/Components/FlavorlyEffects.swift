//
//  FlavorlyEffects.swift
//  Flavorly
//
//

import SwiftUI

// MARK: - Sparkle Particles

struct SparkleParticleOverlay: View {
    @State private var isAnimating = false
    @State private var sparkles: [SparkleData] = []
    
    var body: some View {
        ZStack {
            ForEach(sparkles, id: \.id) { sparkle in
                Image(systemName: "sparkles")
                    .font(.system(size: sparkle.size))
                    .foregroundColor(sparkle.color)
                    .offset(
                        x: isAnimating ? sparkle.finalX : sparkle.startX,
                        y: isAnimating ? sparkle.finalY : sparkle.startY
                    )
                    .opacity(isAnimating ? 0 : sparkle.maxOpacity)
                    .scaleEffect(isAnimating ? 1.5 : 0.5)
                    .animation(
                        Animation.easeOut(duration: sparkle.duration)
                            .delay(sparkle.delay),
                        value: isAnimating
                    )
            }
        }
        .onAppear {
            generateSparkles()
            startAnimation()
        }
    }
    
    private func generateSparkles() {
        sparkles = (0..<20).map { _ in
            SparkleData(
                size: CGFloat.random(in: 12...24),
                color: [Color.yellow.opacity(0.8), Color.white, Color.flavorlyPink.opacity(0.6)].randomElement()!,
                startX: CGFloat.random(in: -150...150),
                startY: CGFloat.random(in: 0...100),
                finalX: CGFloat.random(in: -200...200),
                finalY: CGFloat.random(in: -400...(-200)),
                maxOpacity: Double.random(in: 0.6...1.0),
                duration: Double.random(in: 2...3.5),
                delay: Double.random(in: 0...0.8)
            )
        }
    }
    
    private func startAnimation() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            isAnimating = true
        }
    }
}

struct SparkleData {
    let id = UUID()
    let size: CGFloat
    let color: Color
    let startX: CGFloat
    let startY: CGFloat
    let finalX: CGFloat
    let finalY: CGFloat
    let maxOpacity: Double
    let duration: Double
    let delay: Double
}

// MARK: - Floating Bubbles

struct FloatingBubbleOverlay: View {
    @State private var bubbles: [BubbleData] = []
    
    var body: some View {
        ZStack {
            ForEach(bubbles) { bubble in
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                bubble.color.opacity(0.4),
                                bubble.color.opacity(0.1),
                                Color.clear
                            ],
                            center: .topLeading,
                            startRadius: 5,
                            endRadius: bubble.size / 2
                        )
                    )
                    .frame(width: bubble.size, height: bubble.size)
                    .offset(x: bubble.offsetX, y: bubble.offsetY)
                    .opacity(bubble.opacity)
                    .overlay(
                        Circle()
                            .stroke(bubble.color.opacity(0.3), lineWidth: 1)
                    )
            }
        }
        .onAppear {
            generateBubbles()
            animateBubbles()
        }
    }
    
    private func generateBubbles() {
        bubbles = (0..<8).map { _ in
            BubbleData(
                size: CGFloat.random(in: 60...120),
                color: [Color.flavorlyPink, Color.flavorlyRose, Color.flavorlyPurple, Color.white].randomElement()!,
                offsetX: CGFloat.random(in: -150...150),
                offsetY: CGFloat.random(in: -300...300),
                opacity: Double.random(in: 0.2...0.4)
            )
        }
    }
    
    private func animateBubbles() {
        for i in bubbles.indices {
            animateBubble(at: i)
        }
    }
    
    private func animateBubble(at index: Int) {
        let duration = Double.random(in: 4...8)
        let delay = Double.random(in: 0...2)
        
        withAnimation(
            Animation.easeInOut(duration: duration)
                .repeatForever(autoreverses: true)
                .delay(delay)
        ) {
            bubbles[index].offsetY += CGFloat.random(in: -100...100)
            bubbles[index].offsetX += CGFloat.random(in: -50...50)
            bubbles[index].opacity = Double.random(in: 0.1...0.5)
        }
    }
}

struct BubbleData: Identifiable {
    let id = UUID()
    var size: CGFloat
    var color: Color
    var offsetX: CGFloat
    var offsetY: CGFloat
    var opacity: Double
}

// MARK: - Pulsing Glow

struct PulsingGlowModifier: ViewModifier {
    @State private var isGlowing = false
    let color: Color
    let intensity: CGFloat
    
    func body(content: Content) -> some View {
        content
            .shadow(
                color: color.opacity(isGlowing ? intensity : intensity * 0.3),
                radius: isGlowing ? 20 : 8,
                x: 0,
                y: 0
            )
            .onAppear {
                withAnimation(
                    Animation.easeInOut(duration: 2.0)
                        .repeatForever(autoreverses: true)
                ) {
                    isGlowing = true
                }
            }
    }
}

// MARK: - Breathing Animation

struct BreathingModifier: ViewModifier {
    @State private var isBreathing = false
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(isBreathing ? 1.05 : 1.0)
            .onAppear {
                withAnimation(
                    Animation.easeInOut(duration: 2.5)
                        .repeatForever(autoreverses: true)
                ) {
                    isBreathing = true
                }
            }
    }
}

// MARK: - Shimmer Effect

struct ShimmerModifier: ViewModifier {
    @State private var phase: CGFloat = 0
    let duration: Double
    let color1: Color
    let color2: Color
    
    func body(content: Content) -> some View {
        content
            .overlay(
                LinearGradient(
                    colors: [
                        color1.opacity(0.0),
                        color2.opacity(0.4),
                        color1.opacity(0.0)
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .mask(content)
                .offset(x: phase)
            )
            .onAppear {
                withAnimation(
                    Animation.linear(duration: duration)
                        .repeatForever(autoreverses: false)
                ) {
                    phase = 300
                }
            }
    }
}

// MARK: - Confetti Burst

struct ConfettiBurstView: View {
    @State private var isAnimating = false
    @State private var pieces: [ConfettiPiece] = []
    
    var body: some View {
        ZStack {
            ForEach(pieces) { piece in
                RoundedRectangle(cornerRadius: 2)
                    .fill(piece.color)
                    .frame(width: piece.width, height: piece.height)
                    .offset(
                        x: isAnimating ? piece.finalX : 0,
                        y: isAnimating ? piece.finalY : 0
                    )
                    .rotationEffect(.degrees(isAnimating ? piece.rotation : 0))
                    .opacity(isAnimating ? 0 : 1)
                    .animation(
                        Animation.easeOut(duration: piece.duration)
                            .delay(piece.delay),
                        value: isAnimating
                    )
            }
        }
        .onAppear {
            generateConfetti()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                isAnimating = true
            }
        }
    }
    
    private func generateConfetti() {
        let colors: [Color] = [
            .flavorlyPink, .flavorlyRose, .flavorlyPurple,
            .yellow, .white, .flavorlyPinkLight
        ]
        
        pieces = (0..<30).map { _ in
            ConfettiPiece(
                color: colors.randomElement()!,
                width: CGFloat.random(in: 6...12),
                height: CGFloat.random(in: 12...20),
                finalX: CGFloat.random(in: -200...200),
                finalY: CGFloat.random(in: 200...600),
                rotation: Double.random(in: 0...720),
                duration: Double.random(in: 1.5...3),
                delay: Double.random(in: 0...0.3)
            )
        }
    }
}

struct ConfettiPiece: Identifiable {
    let id = UUID()
    let color: Color
    let width: CGFloat
    let height: CGFloat
    let finalX: CGFloat
    let finalY: CGFloat
    let rotation: Double
    let duration: Double
    let delay: Double
}

// MARK: - Gentle Bounce

struct BounceModifier: ViewModifier {
    @State private var isBouncing = false
    let delay: Double
    
    func body(content: Content) -> some View {
        content
            .offset(y: isBouncing ? -8 : 0)
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                    withAnimation(
                        Animation.easeInOut(duration: 0.6)
                            .repeatForever(autoreverses: true)
                    ) {
                        isBouncing = true
                    }
                }
            }
    }
}

// MARK: - Celebration Effects Combined

struct CelebrationEffectsModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .heartParticles()
            .sparkleParticles()
            .confettiBurst()
    }
}

// MARK: - View Extensions

extension View {
    func sparkleParticles() -> some View {
        overlay(SparkleParticleOverlay().allowsHitTesting(false))
    }
    
    func floatingBubbles() -> some View {
        background(FloatingBubbleOverlay().allowsHitTesting(false))
    }
    
    func pulsingGlow(color: Color = .flavorlyPink, intensity: CGFloat = 0.6) -> some View {
        modifier(PulsingGlowModifier(color: color, intensity: intensity))
    }
    
    func breathing() -> some View {
        modifier(BreathingModifier())
    }
    
    func shimmer(
        duration: Double = 2.0,
        color1: Color = .white,
        color2: Color = .flavorlyPink
    ) -> some View {
        modifier(ShimmerModifier(duration: duration, color1: color1, color2: color2))
    }
    
    func confettiBurst() -> some View {
        overlay(ConfettiBurstView().allowsHitTesting(false))
    }
    
    func gentleBounce(delay: Double = 0) -> some View {
        modifier(BounceModifier(delay: delay))
    }
    
    func celebrationEffects() -> some View {
        modifier(CelebrationEffectsModifier())
    }
    
    func textStroke(color: Color, width: CGFloat = 1) -> some View {
        modifier(StrokeModifier(strokeColor: color, strokeWidth: width))
    }
}

// MARK: - Text Stroke Effect

struct StrokeModifier: ViewModifier {
    let strokeColor: Color
    let strokeWidth: CGFloat
    
    func body(content: Content) -> some View {
        content
            .shadow(color: strokeColor, radius: 1, x: -strokeWidth, y: -strokeWidth)
            .shadow(color: strokeColor, radius: 1, x: strokeWidth, y: -strokeWidth)
            .shadow(color: strokeColor, radius: 1, x: -strokeWidth, y: strokeWidth)
            .shadow(color: strokeColor, radius: 1, x: strokeWidth, y: strokeWidth)
    }
}

