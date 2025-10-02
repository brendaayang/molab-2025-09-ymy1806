import SwiftUI
import Combine
import UIKit

struct AppRootView: View {
    var body: some View {
        TabView {
            TimerView()
                .tabItem {
                    Label("Timer", systemImage: "timer")
                }

            AboutView()
                .tabItem {
                    Label("About", systemImage: "info.circle")
                }
        }
    }
}

struct AboutView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    Text("About This App")
                        .font(.title)
                        .bold()

                    Text("This app demonstrates a SwiftUI countdown timer with a progress ring, live clock, and haptic feedback. Use the wheel pickers to set hours, minutes, and seconds, then Start/Pause or Reset.")
                        .multilineTextAlignment(.center)

                    VStack(alignment: .leading, spacing: 8) {
                        Label("Set duration with the wheels", systemImage: "clock")
                        Label("Tap Start to begin / Pause to pause", systemImage: "play.fill")
                        Label("Reset sets the timer to your selected duration", systemImage: "arrow.counterclockwise")
                        Label("Ring fills as time elapses", systemImage: "circle")
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding()
            }
            .navigationTitle("About")
        }
    }
}

struct TimerView: View {
    // Live clock
    @State private var now = Date()
    private let clock = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    // Countdown
    @State private var hours = 0
    @State private var minutes = 25
    @State private var seconds = 0

    @State private var total: TimeInterval = 25 * 60
    @State private var remaining: TimeInterval = 25 * 60
    @State private var isRunning = false

    // Smooth UI updates while counting
    private let tick = Timer.publish(every: 0.2, on: .main, in: .common).autoconnect()

    private var progress: CGFloat {
        guard total > 0 else { return 0 }
        return CGFloat(1 - (remaining / total))
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 28) {
                // Live clock
                VStack(spacing: 6) {
                    Text(now, style: .time)
                        .font(.system(size: 44, weight: .semibold, design: .rounded))
                        .monospacedDigit()
                    Text(now.formatted(date: .abbreviated, time: .omitted))
                        .foregroundStyle(.secondary)
                }
                .onReceive(clock) { now = $0 }

                // Progress ring + remaining label
                ZStack {
                    Circle()
                        .stroke(lineWidth: 16)
                        .opacity(0.12)

                    Circle()
                        .trim(from: 0, to: progress)
                        .stroke(style: StrokeStyle(lineWidth: 16, lineCap: .round))
                        .rotationEffect(.degrees(-90))
                        .animation(.easeInOut(duration: 0.2), value: progress)

                    VStack(spacing: 8) {
                        Text(format(remaining))
                            .font(.system(size: 40, weight: .bold, design: .rounded))
                            .monospacedDigit()
                        Text(isRunning ? "Counting down…" : "Ready")
                            .foregroundStyle(.secondary)
                    }
                }
                .frame(width: 230, height: 230)
                .padding(.top, 8)
                .onReceive(tick) { _ in
                    guard isRunning else { return }
                    if remaining > 0 {
                        remaining = max(0, remaining - 0.2)
                    } else {
                        isRunning = false
                        Haptic.notify(.success)
                    }
                }

                // Pickers
                HStack(spacing: 14) {
                    Wheel("H", selection: $hours, range: 0..<24)
                    Wheel("M", selection: $minutes, range: 0..<60)
                    Wheel("S", selection: $seconds, range: 0..<60)
                }
                .frame(height: 130)

                // Controls
                HStack(spacing: 12) {
                    Button {
                        if isRunning {
                            isRunning = false
                        } else {
                            let newTotal = TimeInterval(hours * 3600 + minutes * 60 + seconds)
                            total = max(newTotal, 1)
                            remaining = total
                            isRunning = true
                            Haptic.impact(.light)
                        }
                    } label: {
                        Label(isRunning ? "Pause" : "Start", systemImage: isRunning ? "pause.fill" : "play.fill")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)

                    Button {
                        isRunning = false
                        remaining = TimeInterval(hours * 3600 + minutes * 60 + seconds)
                        total = max(remaining, 1)
                        Haptic.impact(.light)
                    } label: {
                        Label("Reset", systemImage: "arrow.counterclockwise")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                }
                .padding(.horizontal)

                Spacer(minLength: 16)
            }
            .padding()
            .navigationTitle("Timer")
            .onAppear {
                let initial = TimeInterval(hours * 3600 + minutes * 60 + seconds)
                total = max(initial, 1)
                remaining = total
            }
        }
    }

    private func format(_ t: TimeInterval) -> String {
        let total = Int(t.rounded(.down))
        let h = total / 3600
        let m = (total % 3600) / 60
        let s = total % 60
        return h > 0 ? String(format: "%d:%02d:%02d", h, m, s)
                      : String(format: "%02d:%02d", m, s)
    }
}

// MARK: - Little helpers

private struct Wheel: View {
    let label: String
    @Binding var selection: Int
    let range: Range<Int>

    init(_ label: String, selection: Binding<Int>, range: Range<Int>) {
        self.label = label
        self._selection = selection
        self.range = range
    }

    var body: some View {
        VStack {
            Picker(label, selection: $selection) {
                ForEach(range, id: \.self) { Text("\($0) \(label.lowercased())") }
            }
            .pickerStyle(.wheel)
        }
        .frame(maxWidth: .infinity)
    }
}

enum Haptic {
    static func impact(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        UIImpactFeedbackGenerator(style: style).impactOccurred()
    }
    static func notify(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        UINotificationFeedbackGenerator().notificationOccurred(type)
    }
}

struct AppRootView_Previews: PreviewProvider {
    static var previews: some View {
        AppRootView()
    }
}
