//
//  LookaheadBeatCoordinator.swift
//  Flavorly
//
//  Created by Brenda Yang on 10/19/25.
//

import Foundation
import AVFoundation

protocol BeatEventSink: AnyObject {
    func didProduce(events: [BeatEvent])
}

final class LookaheadBeatCoordinator {
    private let asset: AVAsset
    private let analyzer: BeatAnalyzer
    private let cache: BeatMapCache
    private let playhead: () -> Double
    private weak var sink: BeatEventSink?
    
    private let primeWindow: Double = 12.0
    private let targetAhead: Double = 20.0
    private let chunkSize: Double = 6.0
    private let chunkOverlap: Double = 1.0
    
    private var allEvents: [BeatEvent] = []
    private var analysisTask: Task<Void, Never>?
    private var isRunning = false
    private var duration: Double = 0
    private var isCancelled = false
    
    init(asset: AVAsset, analyzer: BeatAnalyzer = BeatAnalyzer(), cache: BeatMapCache = BeatMapCache(), playhead: @escaping () -> Double, sink: BeatEventSink) {
        self.asset = asset
        self.analyzer = analyzer
        self.cache = cache
        self.playhead = playhead
        self.sink = sink
        print("🎬 LookaheadCoordinator: Initialized")
    }
    
    func start() {
        guard !isRunning else { return }
        isRunning = true
        print("▶️ LookaheadCoordinator: Starting...")
        
        analysisTask = Task {
            await loadDuration()
            await primeAnalysis()
            await rollAnalysis()
        }
    }
    
    func stop() {
        print("⏹ LookaheadCoordinator: Stopping")
        isCancelled = true
        analyzer.cancel()  // Cancel the analyzer directly
        isRunning = false
        analysisTask?.cancel()
        analysisTask = nil
    }
    
    func onSeek() {
        print("⏩ LookaheadCoordinator: Seek detected, clearing buffer")
        // Don't clear allEvents (keep full analysis), just re-prime from new position
        analysisTask?.cancel()
        analysisTask = Task {
            await primeAnalysis()
            await rollAnalysis()
        }
    }
    
    private func loadDuration() async {
        do {
            let assetDuration = try await asset.load(.duration)
            duration = CMTimeGetSeconds(assetDuration)
            print("📊 LookaheadCoordinator: Asset duration = \(duration)s")
        } catch {
            print("❌ LookaheadCoordinator: Failed to load duration: \(error)")
        }
    }
    
    private func primeAnalysis() async {
        let currentTime = playhead()
        print("🔄 LookaheadCoordinator: Priming from t=\(String(format: "%.2f", currentTime))s")
        
        // Check cache first
        if let url = (asset as? AVURLAsset)?.url {
            let key = cache.cacheKey(for: url, duration: duration)
            if let cached = cache.load(key: key, expectedDuration: duration) {
                print("💾 LookaheadCoordinator: Using cached analysis (\(cached.events.count) events)")
                allEvents = cached.events
                sink?.didProduce(events: cached.events)
                return
            }
        }
        
        // Analyze in chunks (prime window)
        let startTime = Date()
        do {
            guard !isCancelled else {
                print("⚠️ LookaheadCoordinator: Analysis cancelled before completion")
                return
            }
            
            // Analyze prime window from current playhead position
            let start = max(0, min(currentTime, duration - primeWindow))
            let primeRange = CMTimeRange(
                start: CMTime(seconds: start, preferredTimescale: 600),
                duration: CMTime(seconds: min(primeWindow, duration - start), preferredTimescale: 600)
            )
            
            allEvents = try await analyzer.analyze(asset: asset, timeRange: primeRange)
            
            guard !isCancelled else {
                print("⚠️ LookaheadCoordinator: Analysis cancelled after completion")
                return
            }
            
            let elapsed = Date().timeIntervalSince(startTime)
            print("✅ LookaheadCoordinator: Prime analysis complete in \(String(format: "%.3f", elapsed))s")
            
            // Save to cache
            if let url = (asset as? AVURLAsset)?.url {
                let key = cache.cacheKey(for: url, duration: duration)
                cache.save(key: key, events: allEvents, duration: duration, config: analyzer.config)
            }
            
            sink?.didProduce(events: allEvents)
        } catch {
            print("❌ LookaheadCoordinator: Prime analysis failed: \(error)")
        }
    }
    
    private func rollAnalysis() async {
        while isRunning && !Task.isCancelled {
            let currentTime = playhead()
            let futureEvents = allEvents.filter { $0.t > currentTime }
            let eventsAhead = futureEvents.count
            let timeAhead = futureEvents.last.map { $0.t - currentTime } ?? 0
            
            if timeAhead < targetAhead && currentTime + chunkSize < duration {
                print("📊 LookaheadCoordinator: Buffer low (\(String(format: "%.1f", timeAhead))s ahead), analyzing next chunk")
                
                // Analyze next chunk
                let chunkStart = currentTime + timeAhead
                let chunkRange = CMTimeRange(
                    start: CMTime(seconds: chunkStart, preferredTimescale: 600),
                    duration: CMTime(seconds: chunkSize, preferredTimescale: 600)
                )
                
                do {
                    let chunkEvents = try await analyzer.analyze(asset: asset, timeRange: chunkRange)
                    allEvents.append(contentsOf: chunkEvents)
                    allEvents.sort { $0.t < $1.t }
                    sink?.didProduce(events: chunkEvents)
                    // Individual chunk logging removed - too spammy
                } catch {
                    print("❌ LookaheadCoordinator: Chunk analysis failed: \(error)")
                    break  // Stop trying if analysis fails
                }
            }
            
            try? await Task.sleep(nanoseconds: 100_000_000)  // 100ms
        }
        print("🛑 LookaheadCoordinator: Roll loop stopped")
    }
}
