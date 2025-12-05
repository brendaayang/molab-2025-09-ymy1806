//
//  TimerService.swift
//  Flavorly
//
//  Created by Brenda Yang on 10/18/25.
//

import Foundation
import Combine
import UserNotifications
import ActivityKit
import WidgetKit

// MARK: - Live Activity Attributes

struct TimerActivityAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable, Equatable {
        var timerName: String
        var endTime: Date
        var isCompleted: Bool
        var timerColor: String // Store as string for Codable
        
        init(timerName: String, endTime: Date, isCompleted: Bool, timerColor: String) {
            self.timerName = timerName
            self.endTime = endTime
            self.isCompleted = isCompleted
            self.timerColor = timerColor
        }
    }
    
    var timerName: String
    var timerColor: String
}

final class TimerService: TimerServiceProtocol {
    private let storageKey = "flavorly.timers"
    private var updateTimer: Timer?
    private let sharedDefaults: UserDefaults
    private var liveActivities: [UUID: Activity<TimerActivityAttributes>] = [:]
    
    var activeTimers = CurrentValueSubject<[BakingTimer], Never>([])
    
    init() {
        // Use shared UserDefaults for widget access
        self.sharedDefaults = UserDefaults(suiteName: "group.com.flavorly.timers") ?? UserDefaults.standard
        loadTimers()
        startUpdateTimer()
        requestNotificationPermission()
    }
    
    func addTimer(_ timer: BakingTimer) {
        var timers = activeTimers.value
        timers.append(timer)
        activeTimers.send(timers)
        saveTimers()
        scheduleNotification(for: timer)
        startLiveActivity(for: timer)
        
        // Force widget refresh
        WidgetCenter.shared.reloadTimelines(ofKind: "TimerWidget")
    }
    
    func removeTimer(id: UUID) {
        var timers = activeTimers.value
        timers.removeAll { $0.id == id }
        activeTimers.send(timers)
        saveTimers()
        cancelNotification(for: id)
        endLiveActivity(for: id)
        
        // Force widget refresh
        WidgetCenter.shared.reloadTimelines(ofKind: "TimerWidget")
    }
    
    func pauseTimer(id: UUID) {
        var timers = activeTimers.value
        if let index = timers.firstIndex(where: { $0.id == id }) {
            timers[index].isPaused = true
            timers[index].duration = timers[index].remainingTime
            activeTimers.send(timers)
            saveTimers()
            cancelNotification(for: id)
            
            // Force widget refresh
            WidgetCenter.shared.reloadTimelines(ofKind: "TimerWidget")
        }
    }
    
    func resumeTimer(id: UUID) {
        var timers = activeTimers.value
        if let index = timers.firstIndex(where: { $0.id == id }) {
            timers[index].isPaused = false
            timers[index].endTime = Date().addingTimeInterval(timers[index].duration)
            activeTimers.send(timers)
            saveTimers()
            scheduleNotification(for: timers[index])
            
            // Force widget refresh
            WidgetCenter.shared.reloadTimelines(ofKind: "TimerWidget")
        }
    }
    
    func updateTimers() {
        var timers = activeTimers.value
        var hasChanges = false
        
        // Remove completed timers after a delay
        timers.removeAll { timer in
            if timer.isCompleted {
                hasChanges = true
                return true
            }
            return false
        }
        
        if hasChanges {
            activeTimers.send(timers)
            saveTimers()
        }
    }
    
    // MARK: - Private
    
    private func startUpdateTimer() {
        updateTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            // Just trigger UI updates, don't auto-remove
            self?.activeTimers.send(self?.activeTimers.value ?? [])
        }
    }
    
    private func loadTimers() {
        if let data = sharedDefaults.data(forKey: storageKey),
           let timers = try? JSONDecoder().decode([BakingTimer].self, from: data) {
            // Filter out old completed timers
            let validTimers = timers.filter { !$0.isCompleted }
            activeTimers.send(validTimers)
        }
    }
    
    private func saveTimers() {
        if let data = try? JSONEncoder().encode(activeTimers.value) {
            sharedDefaults.set(data, forKey: storageKey)
            sharedDefaults.synchronize()
            
            // Refresh widget timeline
            WidgetCenter.shared.reloadTimelines(ofKind: "TimerWidget")
        }
    }
    
    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("❌ Notification permission error: \(error)")
            } else if granted {
                print("✅ Notification permission granted")
            }
        }
    }
    
    private func scheduleNotification(for timer: BakingTimer) {
        let content = UNMutableNotificationContent()
        content.title = "timer complete! 🎀"
        content.body = "\(timer.name) is done!"
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: timer.remainingTime,
            repeats: false
        )
        
        let request = UNNotificationRequest(
            identifier: timer.id.uuidString,
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ Failed to schedule notification: \(error)")
            }
        }
    }
    
    private func cancelNotification(for id: UUID) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: [id.uuidString]
        )
    }
    
    // MARK: - Live Activity Management
    
    private func startLiveActivity(for timer: BakingTimer) {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else { 
            print("❌ Live Activities not enabled")
            return 
        }
        
        let attributes = TimerActivityAttributes(
            timerName: timer.name,
            timerColor: timer.color.rawValue
        )
        let state = TimerActivityAttributes.ContentState(
            timerName: timer.name,
            endTime: timer.endTime,
            isCompleted: false,
            timerColor: timer.color.rawValue
        )
        
        do {
            let activity = try Activity.request(
                attributes: attributes,
                content: .init(state: state, staleDate: nil)
            )
            liveActivities[timer.id] = activity
            print("✅ Live Activity started: \(activity.id)")
        } catch {
            print("❌ Error starting Live Activity: \(error)")
        }
    }
    
    private func endLiveActivity(for id: UUID) {
        if let activity = liveActivities[id] {
            let finalState = TimerActivityAttributes.ContentState(
                timerName: activity.attributes.timerName,
                endTime: Date(),
                isCompleted: true,
                timerColor: activity.attributes.timerColor
            )
            
            Task {
                await activity.end(ActivityContent(state: finalState, staleDate: nil), dismissalPolicy: .immediate)
            }
            liveActivities.removeValue(forKey: id)
            print("✅ Live Activity ended: \(id)")
        }
    }
    
    deinit {
        updateTimer?.invalidate()
    }
}

