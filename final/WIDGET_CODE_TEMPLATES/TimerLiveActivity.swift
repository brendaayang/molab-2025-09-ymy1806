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

struct TimerActivityAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var timerName: String
        var endTime: Date
        var isCompleted: Bool
    }
    
    var timerName: String
}

// MARK: - Live Activity Views

struct TimerLiveActivityView: View {
    let context: ActivityViewContext<TimerActivityAttributes>
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                // Timer Icon
                Image(systemName: "timer")
                    .font(.title3)
                    .foregroundColor(.flavorlyPink)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(context.state.timerName)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.primary)
                    
                    if context.state.isCompleted {
                        Text("done! 🎀")
                            .font(.system(size: 14))
                            .foregroundColor(.green)
                    } else {
                        Text("ends at \(context.state.endTime, style: .time)")
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                // Countdown
                if !context.state.isCompleted {
                    Text(context.state.endTime, style: .timer)
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(.flavorlyPink)
                        .monospacedDigit()
                }
            }
            .padding()
        }
        .background(Color.white)
    }
}

// MARK: - Dynamic Island Views

struct TimerDynamicIslandView: View {
    let context: ActivityViewContext<TimerActivityAttributes>
    
    var body: some View {
        DynamicIslandExpandedRegion(.leading) {
            VStack(alignment: .leading, spacing: 4) {
                Text(context.state.timerName)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.primary)
                
                if context.state.isCompleted {
                    Text("done! 🎀")
                        .font(.system(size: 12))
                        .foregroundColor(.green)
                } else {
                    Text("time remaining")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                }
            }
        }
        
        DynamicIslandExpandedRegion(.trailing) {
            if !context.state.isCompleted {
                Text(context.state.endTime, style: .timer)
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(.flavorlyPink)
                    .monospacedDigit()
            } else {
                Image(systemName: "checkmark.circle.fill")
                    .font(.largeTitle)
                    .foregroundColor(.green)
            }
        }
        
        DynamicIslandExpandedRegion(.bottom) {
            // Progress bar
            if !context.state.isCompleted {
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 8)
                        
                        RoundedRectangle(cornerRadius: 4)
                            .fill(
                                LinearGradient(
                                    colors: [Color(red: 1.0, green: 0.75, blue: 0.85), Color(red: 1.0, green: 0.65, blue: 0.80)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: geometry.size.width * progressValue(endTime: context.state.endTime), height: 8)
                    }
                }
                .frame(height: 8)
            }
        }
        
        DynamicIslandExpandedRegion(.center) {
            EmptyView()
        }
    }
    
    private func progressValue(endTime: Date) -> CGFloat {
        // This is a simplified version - you'd calculate based on start/end times
        let remaining = endTime.timeIntervalSinceNow
        guard remaining > 0 else { return 1.0 }
        // Placeholder - you'd need to store duration to calculate properly
        return 0.5
    }
}

// MARK: - Live Activity Widget

struct TimerLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: TimerActivityAttributes.self) { context in
            // Lock screen view
            TimerLiveActivityView(context: context)
        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded view
                TimerDynamicIslandView(context: context)
            } compactLeading: {
                Image(systemName: "timer")
                    .foregroundColor(.flavorlyPink)
            } compactTrailing: {
                Text(context.state.endTime, style: .timer)
                    .monospacedDigit()
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.flavorlyPink)
            } minimal: {
                Image(systemName: "timer")
                    .foregroundColor(.flavorlyPink)
            }
        }
    }
}

// MARK: - Helper Extension

private extension Color {
    static let flavorlyPink = Color(red: 1.0, green: 0.75, blue: 0.85)
}

