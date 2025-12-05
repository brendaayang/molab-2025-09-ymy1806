//
//  TimerRowView.swift
//  Flavorly
//
//  Created by Brenda Yang on 10/18/25.
//

import SwiftUI

struct TimerRowView: View {
    let timer: BakingTimer
    let onPause: () -> Void
    let onResume: () -> Void
    let onRemove: () -> Void
    @EnvironmentObject var theme: Theme
    
    var body: some View {
        HStack(spacing: 16) {
            // Progress Ring
            ZStack {
                Circle()
                    .stroke(colorForTimer.opacity(0.3), lineWidth: 8)
                    .frame(width: 70, height: 70)
                
                Circle()
                    .trim(from: 0, to: timer.progress)
                    .stroke(colorForTimer, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                    .frame(width: 70, height: 70)
                    .rotationEffect(.degrees(-90))
                    .animation(.linear(duration: 1), value: timer.progress)
                
                if timer.isCompleted {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title)
                        .foregroundColor(colorForTimer)
                } else {
                    VStack(spacing: 2) {
                        Text(timer.formattedRemainingTime().components(separatedBy: ":").first ?? "")
                            .font(Theme.Fonts.bakeryHeadline)
                            .foregroundColor(.flavorlyPinkDark)
                        
                        Text(timer.formattedRemainingTime().components(separatedBy: ":").last ?? "")
                            .font(Theme.Fonts.bakeryCaption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            // Timer Info
            VStack(alignment: .leading, spacing: 6) {
                Text(timer.name)
                    .font(Theme.Fonts.bakeryHeadline)
                    .foregroundColor(.flavorlyPinkDark)
                
                if timer.isCompleted {
                    Text("done! 🎀")
                        .font(Theme.Fonts.bakeryBody)
                        .foregroundColor(.green)
                } else if timer.isPaused {
                    Text("paused")
                        .font(Theme.Fonts.bakeryBody)
                        .foregroundColor(.orange)
                } else {
                    Text(timer.formattedRemainingTime() + " remaining")
                        .font(Theme.Fonts.bakeryBody)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            // Controls
            if !timer.isCompleted {
                Button {
                    if timer.isPaused {
                        onResume()
                    } else {
                        onPause()
                    }
                } label: {
                    Image(systemName: timer.isPaused ? "play.circle.fill" : "pause.circle.fill")
                        .font(.title2)
                        .foregroundColor(colorForTimer)
                }
            }
            
            Button {
                onRemove()
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.title2)
                    .foregroundColor(.red.opacity(0.7))
            }
        }
        .padding()
        .background(Color.flavorlyWhite)
        .cornerRadius(theme.cornerRadius)
        .shadow(color: colorForTimer.opacity(0.3), radius: 8, x: 0, y: 4)
    }
    
    private var colorForTimer: Color {
        switch timer.color {
        case .pink:
            return .flavorlyPink
        case .rose:
            return .flavorlyRose
        case .peach:
            return Color(red: 1.0, green: 0.8, blue: 0.6)
        case .lavender:
            return Color(red: 0.8, green: 0.7, blue: 1.0)
        }
    }
}

