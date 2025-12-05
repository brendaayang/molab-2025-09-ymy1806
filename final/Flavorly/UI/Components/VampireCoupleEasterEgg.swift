//
//  VampireCoupleEasterEgg.swift
//  Flavorly
//
//  Created by Brenda Yang on 10/18/25.
//

import SwiftUI

struct VampireCoupleEasterEgg: View {
    @Environment(\.dismiss) var dismiss
    @State private var scale: CGFloat = 0.8
    @State private var opacity: Double = 0
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [.flavorlyPink.opacity(0.3), .flavorlyPurple.opacity(0.3)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            .onTapGesture {
                dismiss()
            }
            
            VStack(spacing: 30) {
                // Vampire couple image
                Image("vampire")
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 20)
                    .cornerRadius(20)
                    .shadow(color: .flavorlyPink.opacity(0.5), radius: 20, x: 0, y: 10)
                    .scaleEffect(scale)
                    .opacity(opacity)
                
                // Floating hearts
                HeartParticles()
            }
        }
        .onAppear {
            // Play music
            AudioPlayerService.shared.playEcstasySegment()
            
            // Animate entrance
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                scale = 1.0
                opacity = 1.0
            }
        }
        .onDisappear {
            AudioPlayerService.shared.stopAudio()
        }
    }
}

struct HeartParticles: View {
    @State private var isAnimating = false
    
    var body: some View {
        ZStack {
            ForEach(0..<15, id: \.self) { index in
                Image(systemName: "heart.fill")
                    .foregroundColor(.flavorlyPink.opacity(0.6))
                    .font(.system(size: CGFloat.random(in: 15...30)))
                    .offset(
                        x: isAnimating ? CGFloat.random(in: -150...150) : 0,
                        y: isAnimating ? CGFloat.random(in: -200...50) : 0
                    )
                    .opacity(isAnimating ? 0 : 1)
                    .animation(
                        Animation.easeOut(duration: Double.random(in: 2...4))
                            .repeatForever(autoreverses: false)
                            .delay(Double(index) * 0.1),
                        value: isAnimating
                    )
            }
        }
        .onAppear {
            isAnimating = true
        }
    }
}

