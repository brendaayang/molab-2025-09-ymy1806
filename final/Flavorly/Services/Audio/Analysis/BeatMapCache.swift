//
//  BeatMapCache.swift
//  Flavorly
//
//  Created by Brenda Yang on 10/19/25.
//

import Foundation
import CryptoKit

struct CachedBeatMap: Codable {
    let version: Int
    let duration: Double
    let events: [BeatEvent]
    let analyzer: BeatAnalyzerConfig
    let vibeMode: VibeMode?        // NEW: Cached vibe
    let vibeConfidence: Float?      // NEW: Confidence
}

final class BeatMapCache {
    private let cacheDirectory: URL
    
    init() {
        let cachesDir = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        cacheDirectory = cachesDir.appendingPathComponent("BeatMaps", isDirectory: true)
        
        // Create directory if needed
        try? FileManager.default.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
        print("💾 BeatMapCache: Initialized at \(cacheDirectory.path)")
    }
    
    func cacheKey(for url: URL, duration: Double) -> String {
        let fileName = url.lastPathComponent
        let fileSize = (try? FileManager.default.attributesOfItem(atPath: url.path)[.size] as? UInt64) ?? 0
        let input = "\(fileName)-\(fileSize)-\(duration)"
        
        let hash = SHA256.hash(data: Data(input.utf8))
        let hashString = hash.compactMap { String(format: "%02x", $0) }.joined()
        
        print("🔑 BeatMapCache: Generated key \(hashString) for \(fileName)")
        return hashString
    }
    
    func load(key: String, expectedDuration: Double) -> (events: [BeatEvent], vibeMode: VibeMode?, vibeConfidence: Float?)? {
        let cacheURL = cacheDirectory.appendingPathComponent("\(key).json")
        
        guard FileManager.default.fileExists(atPath: cacheURL.path) else {
            print("⚠️ BeatMapCache: No cache file for key \(key)")
            return nil
        }
        
        do {
            let data = try Data(contentsOf: cacheURL)
            let cached = try JSONDecoder().decode(CachedBeatMap.self, from: data)
            
            // Validate duration match (within 0.1s)
            guard abs(cached.duration - expectedDuration) < 0.1 else {
                print("⚠️ BeatMapCache: Duration mismatch (\(cached.duration) vs \(expectedDuration))")
                return nil
            }
            
            print("✅ BeatMapCache: Loaded \(cached.events.count) events from cache")
            return (cached.events, cached.vibeMode, cached.vibeConfidence)
        } catch {
            print("❌ BeatMapCache: Failed to load cache: \(error)")
            return nil
        }
    }
    
    func save(key: String, events: [BeatEvent], duration: Double, config: BeatAnalyzerConfig, vibeMode: VibeMode? = nil, vibeConfidence: Float? = nil) {
        let cacheURL = cacheDirectory.appendingPathComponent("\(key).json")
        let cached = CachedBeatMap(version: config.version, duration: duration, events: events, analyzer: config, vibeMode: vibeMode, vibeConfidence: vibeConfidence)
        
        do {
            let data = try JSONEncoder().encode(cached)
            try data.write(to: cacheURL)
            print("💾 BeatMapCache: Saved \(events.count) events to cache")
        } catch {
            print("❌ BeatMapCache: Failed to save cache: \(error)")
        }
    }
}
