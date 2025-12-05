//
//  EventCoordinator.swift
//  Flavorly
//
//  Created by Brenda Yang on 10/19/25.
//

import Foundation

final class EventCoordinator {
    private var eventQueue: [BeatEvent] = []
    private var lastFiredEvents: [BeatEvent] = []
    private let coalescingWindow: Double = 0.06  // 60ms
    private let maxConcurrentTransients: Int = 2
    
    // Telemetry
    private var droppedFXCount: Int = 0
    private var totalTriggerSkew: Double = 0
    private var triggerCount: Int = 0
    
    // Priority order (highest first)
    private let eventPriority: [BeatKind: Int] = [
        .drop: 10,
        .sectionBoundary: 9,
        .chorusStart: 8,
        .chorusEnd: 8,
        .buildUp: 7,
        .bass: 6,
        .onset: 5,
        .vocalPhrase: 4,
        .brightnessSpike: 3,
        .sustain: 2,
        .vocalIn: 1,
        .breakdown: 1
    ]
    
    func addEvents(_ events: [BeatEvent]) {
        eventQueue.append(contentsOf: events)
        eventQueue.sort { $0.t < $1.t }
    }
    
    func getEventsToFire(at time: Double, leadTime: Double = 0.075, bpm: Float = 120) -> [BeatEvent] {
        let triggerTime = time + leadTime
        var eventsToFire: [BeatEvent] = []
        
        // Collect events within trigger window (MAX 100 to prevent pile-up)
        var collected = 0
        let maxBatchSize = 100
        while let first = eventQueue.first, first.t <= triggerTime, collected < maxBatchSize {
            eventsToFire.append(eventQueue.removeFirst())
            collected += 1
        }
        
        if collected >= maxBatchSize {
            print("⚠️ EventCoordinator: Hit max batch size (\(maxBatchSize)), may be falling behind")
        }
        
        // Track trigger skew (difference between expected and actual trigger time)
        if !eventsToFire.isEmpty {
            let expectedTime = eventsToFire.first!.t
            let actualTime = time
            let skew = abs(expectedTime - actualTime) * 1000  // Convert to ms
            totalTriggerSkew += skew
            triggerCount += 1
        }
        
        // Beat-relative coalescing window (8% of a beat, clamped 20-100ms)
        let beatDuration = 60.0 / Double(bpm)
        let beatRelativeCoalescingWindow = max(0.02, min(0.10, beatDuration * 0.08))
        
        // Safety check: ensure window is valid
        guard beatRelativeCoalescingWindow > 0 && beatRelativeCoalescingWindow.isFinite else {
            print("⚠️ EventCoordinator: Invalid coalescing window \(beatRelativeCoalescingWindow), using default")
            eventsToFire = coalesceEvents(eventsToFire, window: 0.06)
            return eventsToFire
        }
        
        // Debug logging
        if eventsToFire.count > 10 {
            print("🔍 EventCoordinator: Coalescing \(eventsToFire.count) events with window \(String(format: "%.3f", beatRelativeCoalescingWindow))s")
        }
        
        // Safe coalescing - if it fails, use original events
        let originalEvents = eventsToFire
        eventsToFire = coalesceEvents(eventsToFire, window: beatRelativeCoalescingWindow)
        
        // Validate result
        if eventsToFire.isEmpty && !originalEvents.isEmpty {
            print("⚠️ EventCoordinator: Coalescing returned empty result, using original events")
            eventsToFire = originalEvents
        }
        
        // Apply priority and concurrent limits
        let originalCount = eventsToFire.count
        eventsToFire = applyConflictResolution(eventsToFire)
        
        // Track dropped FX
        if eventsToFire.count < originalCount {
            droppedFXCount += (originalCount - eventsToFire.count)
        }
        
        // Safety validation BEFORE storing
        let validEvents = eventsToFire.filter { $0.strength.isFinite && $0.t.isFinite }
        
        if validEvents.count < eventsToFire.count {
            print("⚠️ EventCoordinator: Filtered out \(eventsToFire.count - validEvents.count) invalid events")
        }
        
        lastFiredEvents = validEvents
        return validEvents
    }
    
    private func coalesceEvents(_ events: [BeatEvent], window: Double = 0.06) -> [BeatEvent] {
        guard !events.isEmpty else { return [] }
        
        // Validate window
        guard window > 0 && window.isFinite else {
            print("⚠️ EventCoordinator: Invalid coalescing window \(window), returning original events")
            return events
        }
        
        // Sort events by time
        let sortedEvents = events.sorted { $0.t < $1.t }
        var coalesced: [BeatEvent] = []
        var i = 0
        
        while i < sortedEvents.count {
            let currentEvent = sortedEvents[i]
            var timeGroup: [BeatEvent] = [currentEvent]
            
            // Find all events within the time window
            var j = i + 1
            while j < sortedEvents.count && (sortedEvents[j].t - currentEvent.t) <= window {
                timeGroup.append(sortedEvents[j])
                j += 1
            }
            
            // Within the time group, coalesce by kind
            var kindGroups: [BeatKind: [BeatEvent]] = [:]
            for event in timeGroup {
                kindGroups[event.kind, default: []].append(event)
            }
            
            // For each kind, keep the strongest event
            for (_, group) in kindGroups {
                guard !group.isEmpty else { continue }
                
                if group.count > 1 {
                    // Find strongest event safely - use manual comparison to avoid max(by:) issues
                    var strongest = group[0]
                    for event in group.dropFirst() {
                        let eventStrength = event.strength.isFinite ? event.strength : 0
                        let strongestStrength = strongest.strength.isFinite ? strongest.strength : 0
                        if eventStrength > strongestStrength {
                            strongest = event
                        }
                    }
                    coalesced.append(strongest)
                } else {
                    coalesced.append(group[0])
                }
            }
            
            i = j
        }
        
        return coalesced
    }
    
    private func applyConflictResolution(_ events: [BeatEvent]) -> [BeatEvent] {
        // Count transients
        let transients = events.filter { 
            [.onset, .drop, .sectionBoundary, .brightnessSpike].contains($0.kind)
        }
        
        if transients.count <= maxConcurrentTransients {
            return events
        }
        
        // Sort by priority and keep top N
        let sorted = transients.sorted { 
            eventPriority[$0.kind, default: 0] > eventPriority[$1.kind, default: 0]
        }
        
        var result = Array(sorted.prefix(maxConcurrentTransients))
        result.append(contentsOf: events.filter { 
            ![.onset, .drop, .sectionBoundary, .brightnessSpike].contains($0.kind)
        })
        
        return result
    }
    
    // MARK: - Telemetry
    
    func getTelemetryData() -> (droppedFX: Int, avgTriggerSkew: Double) {
        let avgSkew = triggerCount > 0 ? totalTriggerSkew / Double(triggerCount) : 0
        return (droppedFXCount, avgSkew)
    }
    
    func resetTelemetry() {
        droppedFXCount = 0
        totalTriggerSkew = 0
        triggerCount = 0
    }
}
