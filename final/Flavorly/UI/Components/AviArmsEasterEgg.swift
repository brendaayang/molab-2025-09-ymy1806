//
//  AviArmsEasterEgg.swift
//  Flavorly
//
//  Created by Brenda Yang on 10/18/25.
//

import SwiftUI

struct AviArmsEasterEgg: View {
    @Environment(\.dismiss) var dismiss
    @State private var scale: CGFloat = 0.5
    @State private var opacity: Double = 0
    @State private var pulseScale: CGFloat = 1.0
    
    var body: some View {
        ZStack {
            // Minimal pink gradient
            LinearGradient(
                colors: [
                    Color.flavorlyPink.opacity(0.15),
                    Color.flavorlyRose.opacity(0.1),
                    Color.flavorlyPurple.opacity(0.15)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            .onTapGesture {
                dismiss()
            }
            
            VStack {
                Spacer()
                
                // Avi Arms - The Flex
                Image("avi_arms")
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: 320)
                    .clipShape(RoundedRectangle(cornerRadius: 24))
                    .overlay(
                        RoundedRectangle(cornerRadius: 24)
                            .stroke(
                                LinearGradient(
                                    colors: [.flavorlyPink, .flavorlyPurple],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 3
                            )
                    )
                    .shadow(color: .flavorlyPink.opacity(0.4), radius: 30, x: 0, y: 15)
                    .scaleEffect(scale * pulseScale)
                    .opacity(opacity)
                
                Spacer()
                
                // Subtle particle effects
                PinkParticles()
            }
        }
        .onAppear {
            // Play ecstasy segment
            AudioPlayerService.shared.playEcstasySegment()
            
            // Entrance animation
            withAnimation(.spring(response: 0.7, dampingFraction: 0.6)) {
                scale = 1.0
                opacity = 1.0
            }
            
            // Gentle pulsing
            withAnimation(
                Animation.easeInOut(duration: 2.0)
                    .repeatForever(autoreverses: true)
            ) {
                pulseScale = 1.05
            }
        }
        .onDisappear {
            AudioPlayerService.shared.stopAudio()
        }
    }
}

struct PinkParticles: View {
    @State private var isAnimating = false
    
    var body: some View {
        ZStack {
            ForEach(0..<20, id: \.self) { index in
                Circle()
                    .fill(Color.flavorlyPink.opacity(0.3))
                    .frame(width: CGFloat.random(in: 4...12))
                    .offset(
                        x: isAnimating ? CGFloat.random(in: -180...180) : 0,
                        y: isAnimating ? CGFloat.random(in: -300...(-100)) : 50
                    )
                    .opacity(isAnimating ? 0 : 0.8)
                    .animation(
                        Animation.easeOut(duration: Double.random(in: 3...5))
                            .repeatForever(autoreverses: false)
                            .delay(Double(index) * 0.15),
                        value: isAnimating
                    )
            }
        }
        .onAppear {
            isAnimating = true
        }
    }
}

