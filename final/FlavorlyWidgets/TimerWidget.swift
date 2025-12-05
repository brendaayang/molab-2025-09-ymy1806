//
//  TimerWidget.swift
//  FlavorlyWidgets
//
//  INSTRUCTIONS: Copy this file to your FlavorlyWidgets folder after creating the widget extension in Xcode
//

import WidgetKit
import SwiftUI

struct TimerWidgetEntry: TimelineEntry {
    let date: Date
    let timers: [BakingTimer]
}

struct TimerWidgetProvider: TimelineProvider {
    func placeholder(in context: Context) -> TimerWidgetEntry {
        TimerWidgetEntry(date: Date(), timers: [])
    }
    
    func getSnapshot(in context: Context, completion: @escaping (TimerWidgetEntry) -> Void) {
        let entry = TimerWidgetEntry(date: Date(), timers: loadTimers())
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<TimerWidgetEntry>) -> Void) {
        let timers = loadTimers()
        let currentDate = Date()
        
        // Create multiple entries for better updates
        var entries: [TimerWidgetEntry] = []
        
        // Current entry
        entries.append(TimerWidgetEntry(date: currentDate, timers: timers))
        
        // If there are active timers, create entries every 30 seconds for the next 5 minutes
        if !timers.isEmpty {
            for i in 1...10 {
                let updateDate = Calendar.current.date(byAdding: .second, value: 30 * i, to: currentDate)!
                let updatedTimers = timers.map { timer in
                    var updatedTimer = timer
                    // Check if timer should be completed based on endTime
                    if updateDate >= timer.endTime {
                        updatedTimer.isActive = false // Mark as inactive instead of completed
                    }
                    return updatedTimer
                }.filter { $0.isActive } // Filter out inactive timers
                
                entries.append(TimerWidgetEntry(date: updateDate, timers: updatedTimers))
            }
        }
        
        // Update every 30 seconds if there are active timers, otherwise every 5 minutes
        let nextUpdate = Calendar.current.date(
            byAdding: timers.isEmpty ? .minute : .second,
            value: timers.isEmpty ? 5 : 30,
            to: currentDate
        )!
        
        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
    
    private func loadTimers() -> [BakingTimer] {
        guard let sharedDefaults = UserDefaults(suiteName: "group.com.flavorly.timers") else {
            print("❌ Widget: Failed to access shared UserDefaults")
            return []
        }
        
        guard let data = sharedDefaults.data(forKey: "flavorly.timers") else {
            print("❌ Widget: No timer data found in shared UserDefaults")
            return []
        }
        
        guard let timers = try? JSONDecoder().decode([BakingTimer].self, from: data) else {
            print("❌ Widget: Failed to decode timer data")
            return []
        }
        
        let activeTimers = timers.filter { $0.isActive }
        print("✅ Widget: Loaded \(activeTimers.count) active timers")
        return activeTimers
    }
}

// MARK: - Small Widget View

struct SmallTimerWidgetView: View {
    let entry: TimerWidgetEntry
    
    var body: some View {
        if let timer = entry.timers.first {
            VStack(spacing: 8) {
                // Progress Ring
                ZStack {
                    Circle()
                        .stroke(Color.white.opacity(0.3), lineWidth: 6)
                    Circle()
                        .trim(from: 0, to: timer.progress)
                        .stroke(Color.white, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                        .rotationEffect(.degrees(-90))
                    
                    Text(timer.formattedRemainingTime())
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                }
                .frame(width: 60, height: 60)
                
                Text(timer.name)
                    .font(.bakeryBody)
                    .foregroundColor(.white)
                    .lineLimit(1)
            }
            .padding()
        } else {
            VStack(spacing: 8) {
                Image(systemName: "clock.fill")
                    .font(.largeTitle)
                    .foregroundColor(.white)
                Text("no timers")
                    .font(.bakeryCaption)
                    .foregroundColor(.white.opacity(0.8))
            }
        }
    }
}

// MARK: - Medium Widget View

struct MediumTimerWidgetView: View {
    let entry: TimerWidgetEntry
    
    var body: some View {
        if entry.timers.isEmpty {
            VStack(spacing: 12) {
                Image(systemName: "clock.fill")
                    .font(.largeTitle)
                    .foregroundColor(.white)
                Text("no active timers")
                    .font(.bakeryHeadline)
                    .foregroundColor(.white)
                Text("tap to add one! 🎀")
                    .font(.bakeryCaption)
                    .foregroundColor(.white.opacity(0.8))
            }
            .padding()
        } else {
            VStack(alignment: .leading, spacing: 12) {
                Text("baking timers 🎀")
                    .font(.bakeryHeadline)
                    .foregroundColor(.white)
                
                ForEach(entry.timers.prefix(3)) { timer in
                    HStack(spacing: 12) {
                        // Mini progress ring
                        ZStack {
                            Circle()
                                .stroke(Color.white.opacity(0.3), lineWidth: 4)
                            Circle()
                                .trim(from: 0, to: timer.progress)
                                .stroke(Color.white, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                                .rotationEffect(.degrees(-90))
                        }
                        .frame(width: 30, height: 30)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(timer.name)
                                .font(.bakeryBody)
                                .foregroundColor(.white)
                                .lineLimit(1)
                            Text(timer.formattedRemainingTime() + " left")
                                .font(.bakeryCaption)
                                .foregroundColor(.white.opacity(0.8))
                        }
                        
                        Spacer()
                    }
                }
            }
            .padding()
        }
    }
}

// MARK: - Widget Configuration

struct TimerWidget: Widget {
    let kind: String = "TimerWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: TimerWidgetProvider()) { entry in
            TimerWidgetEntryView(entry: entry)
            .containerBackground(
                LinearGradient(
                    colors: [Color.flavorlyPink, Color.flavorlyPinkDark],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                for: .widget
            )
        }
        .configurationDisplayName("baking timers")
        .description("keep track of your baking timers")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

struct TimerWidgetEntryView: View {
    @Environment(\.widgetFamily) var family
    var entry: TimerWidgetEntry
    
    var body: some View {
        switch family {
        case .systemSmall:
            SmallTimerWidgetView(entry: entry)
        case .systemMedium:
            MediumTimerWidgetView(entry: entry)
        default:
            SmallTimerWidgetView(entry: entry)
        }
    }
}

#Preview(as: .systemSmall) {
    TimerWidget()
} timeline: {
    TimerWidgetEntry(date: .now, timers: [])
}

// MARK: - Helper Extension

private extension Color {
    static let flavorlyPink = Color(red: 1.0, green: 0.75, blue: 0.85)
    static let flavorlyPinkDark = Color(red: 1.0, green: 0.65, blue: 0.80)
}

