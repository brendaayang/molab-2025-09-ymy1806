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
        
        // Update every minute
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 1, to: currentDate)!
        let entry = TimerWidgetEntry(date: currentDate, timers: timers)
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        
        completion(timeline)
    }
    
    private func loadTimers() -> [BakingTimer] {
        guard let sharedDefaults = UserDefaults(suiteName: "group.com.flavorly.timers"),
              let data = sharedDefaults.data(forKey: "flavorly.timers"),
              let timers = try? JSONDecoder().decode([BakingTimer].self, from: data) else {
            return []
        }
        return timers.filter { !$0.isCompleted }
    }
}

// MARK: - Small Widget View

struct SmallTimerWidgetView: View {
    let entry: TimerWidgetEntry
    
    var body: some View {
        ZStack {
            // Pink gradient background
            LinearGradient(
                colors: [Color(red: 1.0, green: 0.75, blue: 0.85), Color(red: 1.0, green: 0.65, blue: 0.80)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
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
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                    }
                    .frame(width: 60, height: 60)
                    
                    Text(timer.name)
                        .font(.system(size: 11, weight: .semibold))
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
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(.white.opacity(0.8))
                }
            }
        }
    }
}

// MARK: - Medium Widget View

struct MediumTimerWidgetView: View {
    let entry: TimerWidgetEntry
    
    var body: some View {
        ZStack {
            // Pink gradient background
            LinearGradient(
                colors: [Color(red: 1.0, green: 0.75, blue: 0.85), Color(red: 1.0, green: 0.65, blue: 0.80)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            if entry.timers.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "clock.fill")
                        .font(.largeTitle)
                        .foregroundColor(.white)
                    Text("no active timers")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white.opacity(0.8))
                    Text("tap to add one! 🎀")
                        .font(.system(size: 11))
                        .foregroundColor(.white.opacity(0.7))
                }
            } else {
                VStack(alignment: .leading, spacing: 12) {
                    Text("baking timers 🎀")
                        .font(.system(size: 14, weight: .bold))
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
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundColor(.white)
                                    .lineLimit(1)
                                Text(timer.formattedRemainingTime() + " left")
                                    .font(.system(size: 10))
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
}

// MARK: - Widget Configuration

struct TimerWidget: Widget {
    let kind: String = "TimerWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: TimerWidgetProvider()) { entry in
            TimerWidgetEntryView(entry: entry)
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

