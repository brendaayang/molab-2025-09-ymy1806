//
//  TimerLiveActivity.swift
//  FlavorlyWidgets
//
//  INSTRUCTIONS: Copy this file to your FlavorlyWidgets folder after creating the widget extension in Xcode
//

import ActivityKit
import WidgetKit
import SwiftUI

// MARK: - Live Activity Attributes
// Note: TimerActivityAttributes is defined in the main app's TimerService.swift

// MARK: - Live Activity Views

struct TimerLiveActivityView: View {
    let context: ActivityViewContext<TimerActivityAttributes>
    
    var body: some View {
        ZStack {
            // Dynamic gradient background based on timer color
            LinearGradient(
                colors: colorsForTimerColor(context.state.timerColor),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            VStack(spacing: 12) {
                    HStack {
                        // Melody icon with pink background
                        ZStack {
                            Circle()
                                .fill(Color.white.opacity(0.3))
                                .frame(width: 40, height: 40)

                            Image("melody3")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 24, height: 24)
                        }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(context.state.timerName)
                            .font(.bakeryHeadline)
                            .foregroundColor(.white)
                            .lineLimit(1)
                        
                        if context.state.isCompleted {
                            HStack(spacing: 4) {
                                Image("melody_heart")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 16, height: 16)
                                Text("done! 🎀")
                                    .font(.bakeryBody)
                            }
                            .foregroundColor(.white)
                        } else {
                            Text("ends at \(context.state.endTime, style: .time)")
                                .font(.bakeryCaption)
                                .foregroundColor(.white.opacity(0.8))
                        }
                    }
                    
                    Spacer()
                    
                    // Melody image on the right - larger to fill height
                    Image("melody_working")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: 80, maxHeight: .infinity)
                        .clipped()
                }
                
                // Countdown with system fonts
                if !context.state.isCompleted {
                    Text(context.state.endTime, style: .timer)
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .monospacedDigit()
                }
            }
            .padding(16)
        }
        .cornerRadius(12)
    }
}

// MARK: - Dynamic Island Views

// MARK: - Live Activity Widget

struct TimerLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: TimerActivityAttributes.self) { context in
            // Lock screen view
            TimerLiveActivityView(context: context)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(context.state.timerName)
                            .font(.bakeryHeadline)
                            .foregroundColor(.white)
                            .lineLimit(1)
                        
                        if context.state.isCompleted {
                            HStack(spacing: 2) {
                                Image("melody_heart")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 12, height: 12)
                                Text("done! 🎀")
                                    .font(.bakeryBody)
                            }
                            .foregroundColor(.white)
                        } else {
                            Text("time remaining")
                                .font(.bakeryCaption)
                                .foregroundColor(.white.opacity(0.8))
                        }
                    }
                }
                
                DynamicIslandExpandedRegion(.trailing) {
                    if !context.state.isCompleted {
                        Text(context.state.endTime, style: .timer)
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .monospacedDigit()
                    } else {
                        Image("melody_heart")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 20, height: 20)
                    }
                }
                
                DynamicIslandExpandedRegion(.bottom) {
                    if !context.state.isCompleted {
                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Color.white.opacity(0.3))
                                    .frame(height: 6)
                                
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Color.white)
                                    .frame(width: geometry.size.width * 0.5, height: 6)
                            }
                        }
                        .frame(height: 6)
                    }
                }
            } compactLeading: {
                Image(systemName: "timer")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.white)
            } compactTrailing: {
                Text(context.state.endTime, style: .timer)
                    .monospacedDigit()
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.white)
            } minimal: {
                Image(systemName: "timer")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(.white)
            }
        }
    }
}

// MARK: - Helper Extension

private extension Color {
    static let flavorlyPink = Color(red: 1.0, green: 0.75, blue: 0.85)
    static let flavorlyPinkDark = Color(red: 1.0, green: 0.65, blue: 0.80)
    static let flavorlyRose = Color(red: 1.0, green: 0.7, blue: 0.8)
    static let flavorlyRoseDark = Color(red: 0.9, green: 0.6, blue: 0.7)
    static let flavorlyPeach = Color(red: 1.0, green: 0.8, blue: 0.6)
    static let flavorlyPeachDark = Color(red: 0.9, green: 0.7, blue: 0.5)
    static let flavorlyLavender = Color(red: 0.8, green: 0.7, blue: 1.0)
    static let flavorlyLavenderDark = Color(red: 0.7, green: 0.6, blue: 0.9)
}

// MARK: - Color Mapping Function

private func colorsForTimerColor(_ colorString: String) -> [Color] {
    switch colorString {
    case "pink":
        return [.flavorlyPink, .flavorlyPinkDark]
    case "rose":
        return [.flavorlyRose, .flavorlyRoseDark]
    case "peach":
        return [.flavorlyPeach, .flavorlyPeachDark]
    case "lavender":
        return [.flavorlyLavender, .flavorlyLavenderDark]
    default:
        return [.flavorlyPink, .flavorlyPinkDark] // Default to pink
    }
}

