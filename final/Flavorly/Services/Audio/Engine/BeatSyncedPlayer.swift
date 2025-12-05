//
//  BeatSyncedPlayer.swift
//  Flavorly
//
//  Created by Brenda Yang on 10/19/25.
//

import Foundation
import AVFoundation

final class BeatSyncedPlayer: NSObject, BeatEventSink {
    private var coordinator: LookaheadBeatCoordinator?
    private var eventCoordinator = EventCoordinator()
    private var futureEvents: [BeatEvent] = []
    private var timeObserver: Any?
    private let leadTime: Double = 0.075  // 75ms (fallback)
    private var onEventCallback: ((BeatEvent) -> Void)?
    
    private var playheadProvider: (() -> Double)?
    private let bpmProvider: () -> (bpm: Double, conf: Double)
    
    init(asset: AVAsset, playhead: @escaping () -> Double, bpmProvider: @escaping () -> (Double, Double) = { (120, 0) }) {
        self.playheadProvider = playhead
        self.bpmProvider = bpmProvider
        super.init()
        
        let analyzer = BeatAnalyzer()
        let cache = BeatMapCache()
        coordinator = LookaheadBeatCoordinator(
            asset: asset,
            analyzer: analyzer,
            cache: cache,
            playhead: playhead,
            sink: self
        )
        
        print("🎵 BeatSyncedPlayer: Initialized")
    }
    
    func start(onEvent: @escaping (BeatEvent) -> Void) {
        self.onEventCallback = onEvent
        coordinator?.start()
        print("▶️ BeatSyncedPlayer: Started")
    }
    
    func stop() {
        print("🛑 BeatSyncedPlayer: Stopping - cancelling analysis and clearing \(futureEvents.count) queued events")
        coordinator?.stop()
        futureEvents.removeAll()
        print("⏹ BeatSyncedPlayer: Stopped")
    }
    
    func onSeek() {
        futureEvents.removeAll()
        coordinator?.onSeek()
        print("⏩ BeatSyncedPlayer: Seek - cleared future events")
    }
    
    func startTimeObserver(player: AVPlayer) {
        let interval = CMTime(value: 1, timescale: 60)  // 60 Hz
        timeObserver = player.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            self?.checkForEvents(at: CMTimeGetSeconds(time))
        }
        print("⏱ BeatSyncedPlayer: Time observer started at 60Hz")
    }
    
    func stopTimeObserver(player: AVPlayer) {
        if let observer = timeObserver {
            player.removeTimeObserver(observer)
            timeObserver = nil
            print("⏱ BeatSyncedPlayer: Time observer stopped")
        }
    }
    
    private func checkForEvents(at currentTime: Double) {
        // Get real BPM and confidence
        let (bpm, conf) = bpmProvider()
        let beatDuration = 60.0 / max(bpm, 1.0)
        
        // Adaptive visual lead: base 5% beat + measured skew, clamped 30-110ms
        let (_, avgSkew) = eventCoordinator.getTelemetryData()
        let baseLead = conf >= 0.45 ? beatDuration * 0.05 : 0.075
        let adaptiveLead = max(0.030, min(0.110, baseLead + avgSkew / 1000.0))
        
        let eventsToFire = eventCoordinator.getEventsToFire(at: currentTime, leadTime: adaptiveLead, bpm: Float(bpm))
        
        for event in eventsToFire {
            // Removed individual event logging - too noisy
            onEventCallback?(event)
        }
    }
    
    // BeatEventSink
    func didProduce(events: [BeatEvent]) {
        eventCoordinator.addEvents(events)
        // Individual event batch logging removed - too spammy
    }
    
    // MARK: - Telemetry
    
    func getTelemetryData() -> (droppedFX: Int, avgTriggerSkew: Double) {
        return eventCoordinator.getTelemetryData()
    }
    
    func resetTelemetry() {
        eventCoordinator.resetTelemetry()
    }
}
