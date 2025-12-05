//
//  ViewModifiers+Animations.swift
//  Flavorly
//
//  Created by Brenda Yang on 10/18/25.
//

import SwiftUI

// MARK: - Bouncy Scale Button
struct BouncyButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

extension View {
    func bouncyButton() -> some View {
        self.buttonStyle(BouncyButtonStyle())
    }
}

// MARK: - Slide In Animation
struct SlideInModifier: ViewModifier {
    let delay: Double
    @State private var isVisible = false
    
    func body(content: Content) -> some View {
        content
            .offset(x: isVisible ? 0 : -20, y: 0)
            .opacity(isVisible ? 1 : 0)
            .onAppear {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(delay)) {
                    isVisible = true
                }
            }
    }
}

extension View {
    func slideIn(delay: Double = 0) -> some View {
        self.modifier(SlideInModifier(delay: delay))
    }
}

// MARK: - Pop In Animation
struct PopInModifier: ViewModifier {
    @State private var scale: CGFloat = 0.8
    @State private var opacity: Double = 0
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(scale)
            .opacity(opacity)
            .onAppear {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                    scale = 1.0
                    opacity = 1.0
                }
            }
    }
}

extension View {
    func popIn() -> some View {
        self.modifier(PopInModifier())
    }
}

// MARK: - Shake Animation
struct ShakeEffect: GeometryEffect {
    var amount: CGFloat = 10
    var shakesPerUnit = 3
    var animatableData: CGFloat
    
    func effectValue(size: CGSize) -> ProjectionTransform {
        ProjectionTransform(
            CGAffineTransform(
                translationX: amount * sin(animatableData * .pi * CGFloat(shakesPerUnit)),
                y: 0
            )
        )
    }
}

extension View {
    func shake(trigger: Int) -> some View {
        self.modifier(ShakeEffect(animatableData: CGFloat(trigger)))
    }
}

// MARK: - Confetti Effect
struct ConfettiView: View {
    @State private var isAnimating = false
    let colors: [Color] = [.flavorlyPink, .flavorlyPurple, .flavorlyRose, .yellow, .green]
    
    var body: some View {
        ZStack {
            ForEach(0..<50, id: \.self) { index in
                Rectangle()
                    .fill(colors.randomElement() ?? .flavorlyPink)
                    .frame(width: 10, height: 10)
                    .offset(
                        x: isAnimating ? CGFloat.random(in: -200...200) : 0,
                        y: isAnimating ? CGFloat.random(in: -100...800) : -100
                    )
                    .opacity(isAnimating ? 0 : 1)
                    .rotationEffect(.degrees(isAnimating ? Double.random(in: 0...720) : 0))
                    .animation(
                        Animation.easeOut(duration: Double.random(in: 1.5...3))
                            .delay(Double(index) * 0.02),
                        value: isAnimating
                    )
            }
        }
        .onAppear {
            isAnimating = true
        }
    }
}

