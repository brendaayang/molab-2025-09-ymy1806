//
//  BeatAnalyzer.swift
//  Flavorly
//
//  Created by Brenda Yang on 10/19/25.
//

import Foundation
import AVFoundation
import Accelerate

// MARK: - Telemetry Structures

struct AnalysisTelemetry {
    var eventDensity: [BeatKind: Double] = [:]  // events/min
    var chorusDurations: [Double] = []
    var triggerSkew: Double = 0  // ms average
    var droppedFXCount: Int = 0
    var totalEvents: Int = 0
    var analysisTime: Double = 0
    var lastReportTime: Date = Date()
    var estimatedBPM: Float = 120
    var bpmConfidence: Float = 0
    var vibeScores: VibeScores = VibeScores()
    
    mutating func addEvent(_ kind: BeatKind, strength: Float) {
        totalEvents += 1
        // Track event density per minute
        let timeSinceLastReport = Date().timeIntervalSince(lastReportTime)
        if timeSinceLastReport > 0 {
            let eventsPerMinute = 60.0 / timeSinceLastReport
            eventDensity[kind, default: 0] += eventsPerMinute
        }
    }
    
    mutating func addChorusDuration(_ duration: Double) {
        chorusDurations.append(duration)
    }
    
    mutating func addTriggerSkew(_ skew: Double) {
        triggerSkew = (triggerSkew + skew) / 2.0  // Running average
    }
    
    mutating func incrementDroppedFX() {
        droppedFXCount += 1
    }
    
    mutating func reset() {
        eventDensity.removeAll()
        chorusDurations.removeAll()
        triggerSkew = 0
        droppedFXCount = 0
        totalEvents = 0
        analysisTime = 0
        lastReportTime = Date()
    }
}

final class BeatAnalyzer {
    let config: BeatAnalyzerConfig
    private var fftSetup: vDSP_DFT_Setup?
    
    // Cancellation support
    private var isCancelled = false
    
    // Telemetry
    private var telemetry = AnalysisTelemetry()
    private var lastTelemetryReport: Date = Date()
    private let telemetryInterval: TimeInterval = 30.0  // Report every 30 seconds
    
    init(config: BeatAnalyzerConfig = BeatAnalyzerConfig()) {
        self.config = config
        self.fftSetup = vDSP_DFT_zop_CreateSetup(
            nil,
            vDSP_Length(config.frameSize),
            .FORWARD
        )
        print("🔬 BeatAnalyzer: Initialized with frame=\(config.frameSize), hop=\(config.hopSize)")
    }
    
    deinit {
        if let setup = fftSetup {
            vDSP_DFT_DestroySetup(setup)
        }
    }
    
    func cancel() {
        print("🛑 BeatAnalyzer: Cancellation requested")
        isCancelled = true
    }
    
    func analyze(asset: AVAsset, timeRange: CMTimeRange? = nil) async throws -> [BeatEvent] {
        let startTime = Date()
        // Individual analysis logging removed - too spammy
        
        // Setup AVAssetReader
        let reader = try AVAssetReader(asset: asset)
        guard let audioTrack = try await asset.loadTracks(withMediaType: .audio).first else {
            throw NSError(domain: "BeatAnalyzer", code: 1, userInfo: [NSLocalizedDescriptionKey: "No audio track"])
        }
        
        // Configure output: Float32 PCM, mono, 44.1kHz
        let outputSettings: [String: Any] = [
            AVFormatIDKey: kAudioFormatLinearPCM,
            AVLinearPCMIsFloatKey: true,
            AVLinearPCMBitDepthKey: 32,
            AVLinearPCMIsNonInterleaved: false,
            AVSampleRateKey: config.sampleRate,
            AVNumberOfChannelsKey: 1  // mono (downmix stereo)
        ]
        
        let output = AVAssetReaderTrackOutput(track: audioTrack, outputSettings: outputSettings)
        reader.add(output)
        
        if let range = timeRange {
            reader.timeRange = range
            print("📊 BeatAnalyzer: Analyzing time range \(CMTimeGetSeconds(range.start))s - \(CMTimeGetSeconds(range.end))s")
        }
        
        try reader.startReading()
        
        // Read all PCM samples
        var allSamples: [Float] = []
        while reader.status == .reading {
            guard let sampleBuffer = output.copyNextSampleBuffer() else { break }
            
            if let blockBuffer = CMSampleBufferGetDataBuffer(sampleBuffer) {
                let length = CMBlockBufferGetDataLength(blockBuffer)
                var data = Data(count: length)
                data.withUnsafeMutableBytes { ptr in
                    CMBlockBufferCopyDataBytes(blockBuffer, atOffset: 0, dataLength: length, destination: ptr.baseAddress!)
                }
                
                let floatCount = length / MemoryLayout<Float>.size
                data.withUnsafeBytes { (ptr: UnsafeRawBufferPointer) in
                    let floatPtr = ptr.bindMemory(to: Float.self)
                    allSamples.append(contentsOf: Array(floatPtr))
                }
            }
        }
        
        print("✅ BeatAnalyzer: Read \(allSamples.count) samples (\(Double(allSamples.count)/Double(config.sampleRate))s)")
        
        // Compute spectral flux and bass envelopes
        let (fluxEnvelope, bassEnvelope, timeStamps, frequencyBands) = computeEnvelopes(samples: allSamples)
        // Individual feature logging removed - too spammy
        
        // Estimate BPM from onset envelope
        let onsetEnv = cleanedOnsetEnvelope(fluxEnvelope)
        let (bpmEst, bpmConf) = estimateBPM(onsetEnv: onsetEnv)
        print("🕒 Tempo ~\(Int(bpmEst)) BPM (conf \(String(format: "%.2f", bpmConf)))")
        telemetry.estimatedBPM = bpmEst
        telemetry.bpmConfidence = bpmConf
        
        // Check for empty arrays before detection
        guard !fluxEnvelope.isEmpty && !bassEnvelope.isEmpty && !timeStamps.isEmpty else {
            print("⚠️ BeatAnalyzer: Empty envelopes, skipping detection")
            return []
        }
        
        // Check for cancellation before detection
        guard !isCancelled else {
            print("⚠️ BeatAnalyzer: Analysis cancelled before detection")
            return []
        }
        
        // Check for Task cancellation
        guard !Task.isCancelled else {
            print("⚠️ BeatAnalyzer: Task cancelled before detection")
            return []
        }
        
        // Update telemetry early
        telemetry.analysisTime = Date().timeIntervalSince(startTime)
        
        // Compute additional features for new detection methods
        print("🔍 BeatAnalyzer: Computing additional features...")
        
        let chromagram: [[Float]]
        let rmsEnvelope: [Float]
        let pitchConfidence: [Float]
        let midbandEnergy: [Float]
        let energySlope: [Float]
        let onsetDensity: [Float]
        let spectralCentroid: [Float]
        
        do {
            chromagram = try timed("chromagram", budgetMs: 120.0) {
                computeChromagram(samples: allSamples, timeStamps: timeStamps)
            } ?? []
            // Individual feature logging removed - too spammy
        } catch {
            print("❌ BeatAnalyzer: Chromagram computation failed: \(error)")
            throw error
        }
        
        do {
            rmsEnvelope = try timed("RMS envelope", budgetMs: 120.0) {
                computeRMSEnvelope(samples: allSamples, timeStamps: timeStamps)
            } ?? []
            // Individual feature logging removed - too spammy
        } catch {
            print("❌ BeatAnalyzer: RMS envelope computation failed: \(error)")
            throw error
        }
        
        do {
            pitchConfidence = try timed("pitch confidence", budgetMs: 120.0) {
                computePitchConfidence(samples: allSamples, timeStamps: timeStamps)
            } ?? []
            // Individual feature logging removed - too spammy
        } catch {
            print("❌ BeatAnalyzer: Pitch confidence computation failed: \(error)")
            throw error
        }
        
        do {
            midbandEnergy = try timed("midband energy", budgetMs: 120.0) {
                computeMidbandEnergy(samples: allSamples, timeStamps: timeStamps)
            } ?? []
            // Individual feature logging removed - too spammy
        } catch {
            print("❌ BeatAnalyzer: Midband energy computation failed: \(error)")
            throw error
        }
        
        do {
            energySlope = try timed("energy slope", budgetMs: 120.0) {
                computeEnergySlope(rmsEnvelope: rmsEnvelope)
            } ?? []
            // Individual feature logging removed - too spammy
        } catch {
            print("❌ BeatAnalyzer: Energy slope computation failed: \(error)")
            throw error
        }
        
        // Detect onsets first (needed for onset density)
        let onsets = detectPeaks(
            envelope: fluxEnvelope,
            timeStamps: timeStamps,
            windowSec: config.fluxWindow,
            multiplier: config.fluxMultiplier,
            kind: .onset
        )
        
        do {
            onsetDensity = try timed("onset density", budgetMs: 120.0) {
                self.onsetDensity(onsets: onsets, samplingTimes: timeStamps)
            } ?? []
            // Individual feature logging removed - too spammy
        } catch {
            print("❌ BeatAnalyzer: Onset density computation failed: \(error)")
            throw error
        }
        
        do {
            spectralCentroid = try timed("spectral centroid", budgetMs: 120.0) {
                computeSpectralCentroid(samples: allSamples, timeStamps: timeStamps)
            } ?? []
            // Individual feature logging removed - too spammy
        } catch {
            print("❌ BeatAnalyzer: Spectral centroid computation failed: \(error)")
            throw error
        }
        
        print("✅ BeatAnalyzer: All features computed, starting detection...")
        
        // Store features for detection
        let features = (chromagram: chromagram, rmsEnvelope: rmsEnvelope, pitchConfidence: pitchConfidence, midbandEnergy: midbandEnergy, energySlope: energySlope, onsetDensity: onsetDensity, spectralCentroid: spectralCentroid)
        
        // Compute vibe scores from available features
        let avgRMS = rmsEnvelope.isEmpty ? 0 : rmsEnvelope.reduce(0, +) / Float(rmsEnvelope.count)
        let avgCentroid = spectralCentroid.isEmpty ? 0 : spectralCentroid.reduce(0, +) / Float(spectralCentroid.count)
        let avgPitchConf = pitchConfidence.isEmpty ? 0 : pitchConfidence.reduce(0, +) / Float(pitchConfidence.count)
        let avgOnsetDensity = onsetDensity.isEmpty ? 0 : onsetDensity.reduce(0, +) / Float(onsetDensity.count)

        // Compute crest factor (peak / RMS) for compression measure
        let peakValue = rmsEnvelope.max() ?? 0
        let crestFactor = avgRMS > 0 ? peakValue / avgRMS : 1.0
        let compressionScore = 1.0 - min(crestFactor / 10.0, 1.0)  // Normalized

        let vibeScores = VibeScores(
            bpm: bpmEst,
            bpmConfidence: bpmConf,
            energy: min(avgRMS * 2.0, 1.0),  // Normalized RMS
            brightness: avgCentroid,
            vocality: avgPitchConf,
            space: 0.5,  // TODO: Implement decay tail analysis
            density: avgOnsetDensity,
            compression: compressionScore,
            valence: 0.5  // TODO: Implement key/mode detection
        )

        telemetry.vibeScores = vibeScores
        
        // Onsets already detected above for onset density calculation
        // Individual detection logging removed - will show in summary
        
        // Check for cancellation after each major step
        guard !isCancelled else {
            print("⚠️ BeatAnalyzer: Analysis cancelled after onset detection")
            return []
        }
        
        // Check for Task cancellation after each major step
        guard !Task.isCancelled else {
            print("⚠️ BeatAnalyzer: Task cancelled after onset detection")
            return []
        }
        
        // Detect bass hits
        // Individual detection logging removed - too spammy
        let bassHits = detectPeaks(
            envelope: bassEnvelope,
            timeStamps: timeStamps,
            windowSec: config.bassWindow,
            multiplier: config.bassMultiplier,
            kind: .bass,
            frequencyBands: frequencyBands
        )
        // Individual detection logging removed - will show in summary
        
        // Check for cancellation after each major step
        guard !isCancelled else {
            print("⚠️ BeatAnalyzer: Analysis cancelled after bass detection")
            return []
        }
        
        // Check for Task cancellation after each major step
        guard !Task.isCancelled else {
            print("⚠️ BeatAnalyzer: Task cancelled after bass detection")
            return []
        }
        
        // Detect drops
        // Individual detection logging removed - too spammy
        let drops = detectDrops(
            fluxEnvelope: fluxEnvelope,
            bassEnvelope: bassEnvelope,
            timeStamps: timeStamps,
            onsets: onsets
        )
        // Individual detection logging removed - will show in summary
        
        // Check for cancellation after each major step
        guard !isCancelled else {
            print("⚠️ BeatAnalyzer: Analysis cancelled after drop detection")
            return []
        }
        
            // NEW: Detect additional event types
            let chorusEvents = detectChorus(chromagram: features.chromagram, rmsEnvelope: features.rmsEnvelope, timeStamps: timeStamps)
            let sectionBoundaries = detectSectionBoundaries(chromagram: features.chromagram, timeStamps: timeStamps)
            let vocalEvents = detectVocals(pitchConfidence: features.pitchConfidence, midbandEnergy: features.midbandEnergy, timeStamps: timeStamps)
            let buildUps = detectBuildUps(energySlope: features.energySlope, onsetDensity: features.onsetDensity, timeStamps: timeStamps)
            let breakdowns = detectBreakdowns(rmsEnvelope: features.rmsEnvelope, timeStamps: timeStamps)
            let brightnessSpikes = detectBrightnessSpikes(spectralCentroid: features.spectralCentroid, timeStamps: timeStamps)
            let sustains = detectSustains(onsetDensity: features.onsetDensity, rmsEnvelope: features.rmsEnvelope, timeStamps: timeStamps)
        
        // Combine and sort
        var allEvents = onsets + bassHits + drops + chorusEvents + sectionBoundaries + vocalEvents + buildUps + breakdowns + brightnessSpikes + sustains
        allEvents.sort { $0.t < $1.t }
        
        // Aggregate counts for summary logging
        var counts: [BeatKind: Int] = [:]
        for event in allEvents {
            counts[event.kind, default: 0] += 1
        }
        
        // Single summary line
        let summary = counts.map { "\($0.key.rawValue):\($0.value)" }.joined(separator: ", ")
        
        let elapsed = Date().timeIntervalSince(startTime)
        print("✅ Analysis: \(allEvents.count) events (\(summary)) in \(String(format: "%.3f", elapsed))s")
        
        // Update telemetry
        telemetry.analysisTime = elapsed
        for event in allEvents {
            telemetry.addEvent(event.kind, strength: event.strength)
        }
        
        // Check if we should report telemetry
        if Date().timeIntervalSince(lastTelemetryReport) >= telemetryInterval {
            printTelemetry()
            lastTelemetryReport = Date()
        }
        
        return allEvents
    }
    
    @discardableResult
    private func timed<T>(_ label: String, budgetMs: Double = 120.0, _ body: () throws -> T) throws -> T? {
        let t0 = CACurrentMediaTime()
        do {
            let r = try body()
            let ms = (CACurrentMediaTime() - t0) * 1000
            if ms > budgetMs {
                print("⏱️ BeatAnalyzer: \(label) took \(Int(ms))ms (> \(Int(budgetMs))ms) — consider downsampling")
            }
            return r
        } catch {
            let ms = (CACurrentMediaTime() - t0) * 1000
            print("⏱️ BeatAnalyzer: \(label) failed after \(Int(ms))ms")
            throw error
        }
    }
    
    private func computeEnvelopes(samples: [Float]) -> (flux: [Float], bass: [Float], times: [Double], frequencyBands: [[Float: Float]]) {
        let frameCount = (samples.count - config.frameSize) / config.hopSize
        var fluxEnvelope: [Float] = []
        var bassEnvelope: [Float] = []
        var timeStamps: [Double] = []
        var frequencyBands: [[Float: Float]] = []
        
        var previousMagnitudes: [Float] = Array(repeating: 0, count: config.frameSize / 2)
        
        // Hann window
        var window = [Float](repeating: 0, count: config.frameSize)
        vDSP_hann_window(&window, vDSP_Length(config.frameSize), Int32(vDSP_HANN_NORM))
        
        for frameIndex in 0..<frameCount {
            let offset = frameIndex * config.hopSize
            let frame = Array(samples[offset..<(offset + config.frameSize)])
            
            // Apply Hann window
            var windowed = [Float](repeating: 0, count: config.frameSize)
            vDSP_vmul(frame, 1, window, 1, &windowed, 1, vDSP_Length(config.frameSize))
            
            // FFT with separate in/out buffers (prevents corruption)
            var inReal = windowed
            var inImag = [Float](repeating: 0, count: config.frameSize)
            var outReal = [Float](repeating: 0, count: config.frameSize)
            var outImag = [Float](repeating: 0, count: config.frameSize)
            
            guard let setup = fftSetup else { continue }
            vDSP_DFT_Execute(setup, inReal, inImag, &outReal, &outImag)
            
            // Compute magnitudes from output buffers
            var magnitudes = [Float](repeating: 0, count: config.frameSize / 2)
            for i in 0..<magnitudes.count {
                magnitudes[i] = sqrt(outReal[i] * outReal[i] + outImag[i] * outImag[i])
            }
            
            // Spectral flux (positive changes only)
            var flux: Float = 0
            for i in 0..<magnitudes.count {
                let diff = magnitudes[i] - previousMagnitudes[i]
                if diff > 0 { flux += diff }
            }
            fluxEnvelope.append(flux)
            
            // Bass energy (20-160 Hz)
            let binWidth = config.sampleRate / Float(config.frameSize)
            let bassStartBin = Int(config.bassFreqRange.0 / binWidth)
            let bassEndBin = Int(config.bassFreqRange.1 / binWidth)
            let bassEnergy = magnitudes[bassStartBin..<min(bassEndBin, magnitudes.count)].reduce(0, +)
            bassEnvelope.append(bassEnergy)
            
            // Extract frequency bands for this frame with vocal awareness
            let framePitchConf = computeFramePitchConfidence(magnitudes: magnitudes, sampleRate: Double(config.sampleRate))
            let frameBands = extractFrequencyBands(
                from: magnitudes, 
                sampleRate: Double(config.sampleRate), 
                fftSize: config.frameSize,
                pitchConfidence: framePitchConf
            )
            frequencyBands.append(frameBands)
            
            // Time stamp
            let time = Double(offset) / Double(config.sampleRate)
            timeStamps.append(time)
            
            previousMagnitudes = magnitudes
        }
        
        // Normalize envelopes
        if let maxFlux = fluxEnvelope.max(), maxFlux > 0 {
            fluxEnvelope = fluxEnvelope.map { $0 / maxFlux }
        }
        if let maxBass = bassEnvelope.max(), maxBass > 0 {
            bassEnvelope = bassEnvelope.map { $0 / maxBass }
        }
        
        // Normalize frequency bands across all frames (like bass/flux)
        var maxBands: [Float: Float] = [
            250: 0, 500: 0, 1000: 0, 2000: 0, 4000: 0, 8000: 0
        ]
        
        // Find max for each frequency
        for frameBands in frequencyBands {
            for (freq, energy) in frameBands {
                maxBands[freq] = max(maxBands[freq] ?? 0, energy)
            }
        }
        
        // Normalize each frame's bands to 0-1 range
        for i in 0..<frequencyBands.count {
            var normalized: [Float: Float] = [:]
            for (freq, energy) in frequencyBands[i] {
                let maxVal = maxBands[freq] ?? 1.0
                normalized[freq] = maxVal > 0 ? energy / maxVal : 0
            }
            frequencyBands[i] = normalized
        }
        
        // Debug log sample of normalized bands
        if !frequencyBands.isEmpty && frequencyBands.count > 10 {
            let sample = frequencyBands[10]
            print("📊 NORMALIZED BANDS sample: mid1=\(String(format: "%.3f", sample[250] ?? 0)) mid2=\(String(format: "%.3f", sample[500] ?? 0)) mid3=\(String(format: "%.3f", sample[1000] ?? 0)) high1=\(String(format: "%.3f", sample[2000] ?? 0)) high2=\(String(format: "%.3f", sample[4000] ?? 0)) high3=\(String(format: "%.3f", sample[8000] ?? 0))")
        }
        
        return (fluxEnvelope, bassEnvelope, timeStamps, frequencyBands)
    }
    
    // Extract frequency bands for visualizer
    private func extractFrequencyBands(from magnitudes: [Float], sampleRate: Double, fftSize: Int, pitchConfidence: Float = 0) -> [Float: Float] {
        // Band centers: 250Hz, 500Hz, 1000Hz, 2000Hz, 4000Hz, 8000Hz
        let bands: [(freq: Float, range: (Float, Float))] = [
            (250, (200, 315)),   // Low-mid
            (500, (400, 630)),   // Mid
            (1000, (800, 1260)), // Upper-mid
            (2000, (1600, 2520)), // Presence
            (4000, (3200, 5040)), // Brilliance
            (8000, (6400, 10080)) // Air
        ]
        
        var bandEnergies: [Float: Float] = [:]
        
        for band in bands {
            let binLow = Int(band.range.0 * Float(fftSize) / Float(sampleRate))
            let binHigh = Int(band.range.1 * Float(fftSize) / Float(sampleRate))
            
            guard binLow < magnitudes.count, binHigh < magnitudes.count else { continue }
            
            // Sum energy in band
            var energy: Float = 0
            for bin in binLow...min(binHigh, magnitudes.count - 1) {
                energy += magnitudes[bin]
            }
            
        // Normalize by band width
        let bandWidth = Float(binHigh - binLow + 1)
        var normalizedEnergy = energy / bandWidth
        
        // Apply vocal weighting to frequency bands
        if pitchConfidence > 0.3 {  // Vocals detected
            // Boost vocal frequency range (200Hz-2kHz)
            switch band.freq {
            case 250:  normalizedEnergy *= (1.0 + pitchConfidence * 0.3)  // Vocal low end
            case 500:  normalizedEnergy *= (1.0 + pitchConfidence * 0.6)  // Fundamental
            case 1000: normalizedEnergy *= (1.0 + pitchConfidence * 0.8)  // Formant 1 (strongest)
            case 2000: normalizedEnergy *= (1.0 + pitchConfidence * 0.7)  // Formant 2
            case 4000: normalizedEnergy *= (1.0 + pitchConfidence * 0.4)  // Consonants
            default: break
            }
        }
        
        bandEnergies[band.freq] = normalizedEnergy
        }
        
        return bandEnergies
    }
    
    private func computeFramePitchConfidence(magnitudes: [Float], sampleRate: Double) -> Float {
        // Look for harmonic structure in vocal range (80Hz-800Hz)
        let binWidth = Float(sampleRate) / Float(config.frameSize)
        let startBin = Int(80 / binWidth)
        let endBin = Int(800 / binWidth)
        
        guard startBin < magnitudes.count, endBin < magnitudes.count else { return 0 }
        
        // Simple harmonic detection: check if energy is concentrated in harmonically related bins
        var harmonicStrength: Float = 0
        let fundamentalBin = startBin + 5  // ~100Hz
        
        // Check for harmonics at 2x, 3x, 4x fundamental
        for harmonic in 1...4 {
            let harmonicBin = fundamentalBin * harmonic
            if harmonicBin < endBin {
                harmonicStrength += magnitudes[harmonicBin]
            }
        }
        
        let totalEnergy = magnitudes[startBin...endBin].reduce(0, +)
        return totalEnergy > 0 ? min(harmonicStrength / totalEnergy, 1.0) : 0
    }
    
    private func detectPeaks(envelope: [Float], timeStamps: [Double], windowSec: Double, multiplier: Float, kind: BeatKind, frequencyBands: [[Float: Float]]? = nil) -> [BeatEvent] {
        var events: [BeatEvent] = []
        let windowFrames = Int(windowSec / (Double(config.hopSize) / Double(config.sampleRate)))
        
        for i in 0..<envelope.count {
            let start = max(0, i - windowFrames / 2)
            let end = min(envelope.count, i + windowFrames / 2)
            let localMean = envelope[start..<end].reduce(0, +) / Float(end - start)
            let threshold = localMean * multiplier
            
            // Local maximum above threshold
            if envelope[i] > threshold {
                let isLocalMax = (i == 0 || envelope[i] > envelope[i-1]) &&
                                 (i == envelope.count - 1 || envelope[i] > envelope[i+1])
                if isLocalMax {
                    let strength = min((envelope[i] - threshold) / (1.0 - threshold), 1.0)
                    let frameBands = frequencyBands?[i] ?? [:]
                    events.append(createBeatEvent(t: timeStamps[i], kind: kind, strength: strength, frequencyBands: frameBands))
                }
            }
        }
        
        return events
    }
    
    private func detectDrops(fluxEnvelope: [Float], bassEnvelope: [Float], timeStamps: [Double], onsets: [BeatEvent]) -> [BeatEvent] {
        var drops: [BeatEvent] = []
        let maxFlux = fluxEnvelope.max() ?? 1.0
        let windowFrames = Int(1.5 / (Double(config.hopSize) / Double(config.sampleRate)))
        let preDipFrames = Int(0.8 / (Double(config.hopSize) / Double(config.sampleRate)))
        
        for onset in onsets where onset.kind == .onset {
            guard let frameIndex = timeStamps.firstIndex(where: { abs($0 - onset.t) < 0.05 }) else { continue }
            
            // Check if large onset
            if fluxEnvelope[frameIndex] < config.dropThreshold * maxFlux { continue }
            
            // Check for pre-dip
            let preDipStart = max(0, frameIndex - preDipFrames)
            let preDipEnergy = fluxEnvelope[preDipStart..<frameIndex].reduce(0, +) / Float(frameIndex - preDipStart)
            
            let localStart = max(0, frameIndex - windowFrames)
            let localEnd = min(fluxEnvelope.count, frameIndex + windowFrames)
            let localMedian = fluxEnvelope[localStart..<localEnd].sorted()[fluxEnvelope[localStart..<localEnd].count / 2]
            
            if preDipEnergy < 0.5 * localMedian {
                drops.append(createBeatEvent(t: onset.t, kind: .drop, strength: onset.strength))
            }
        }
        
        return drops
    }
    
    // MARK: - Feature Computation Methods
    
    private func computeChromagram(samples: [Float], timeStamps: [Double]) -> [[Float]] {
        var chromagram: [[Float]] = []
        let chromaBins = 12  // C, C#, D, ..., B
        
        for i in 0..<timeStamps.count {
            let offset = i * config.hopSize
            guard offset + config.frameSize < samples.count else { break }
            
            let frame = Array(samples[offset..<(offset + config.frameSize)])
            let chroma = computeChromaVector(frame: frame)
            chromagram.append(chroma)
        }
        
        return chromagram
    }
    
    private func computeChromaVector(frame: [Float]) -> [Float] {
        let chromaBins = 12
        var chroma = Array(repeating: Float(0), count: chromaBins)
        
        // Apply Hann window
        var window = [Float](repeating: 0, count: config.frameSize)
        vDSP_hann_window(&window, vDSP_Length(config.frameSize), Int32(vDSP_HANN_NORM))
        
        var windowed = [Float](repeating: 0, count: config.frameSize)
        vDSP_vmul(frame, 1, window, 1, &windowed, 1, vDSP_Length(config.frameSize))
        
        // FFT with separate in/out buffers (prevents corruption)
        var inReal = windowed
        var inImag = [Float](repeating: 0, count: config.frameSize)
        var outReal = [Float](repeating: 0, count: config.frameSize)
        var outImag = [Float](repeating: 0, count: config.frameSize)
        
        guard let setup = fftSetup else { return chroma }
        vDSP_DFT_Execute(setup, inReal, inImag, &outReal, &outImag)
        
        // Compute magnitudes from output buffers
        var magnitudes = [Float](repeating: 0, count: config.frameSize / 2)
        for i in 0..<magnitudes.count {
            magnitudes[i] = sqrt(outReal[i] * outReal[i] + outImag[i] * outImag[i])
        }
        
        // Map to chroma bins using log-pitch mapping
        let binWidth = config.sampleRate / Float(config.frameSize)
        for i in 0..<magnitudes.count {
            let freq = Float(i) * binWidth
            if let chromaBin = chromaIndex(for: freq) {
                chroma[chromaBin] += magnitudes[i]
            }
        }
        
        // Normalize
        let maxVal = chroma.max() ?? 1.0
        if maxVal > 0 {
            chroma = chroma.map { $0 / maxVal }
        }
        
        return chroma
    }
    
    private func computeRMSEnvelope(samples: [Float], timeStamps: [Double]) -> [Float] {
        var rmsEnvelope: [Float] = []
        
        for i in 0..<timeStamps.count {
            let offset = i * config.hopSize
            guard offset + config.hopSize < samples.count else { break }
            
            let frame = Array(samples[offset..<(offset + config.hopSize)])
            let rms = sqrt(frame.map { $0 * $0 }.reduce(0, +) / Float(frame.count))
            rmsEnvelope.append(20 * log10(max(rms, 1e-6)))  // Convert to dB
        }
        
        return rmsEnvelope
    }
    
    private func computePitchConfidence(samples: [Float], timeStamps: [Double]) -> [Float] {
        let N = config.frameSize
        let H = config.hopSize
        let sr = config.sampleRate

        // Process every 4th frame
        let step = 4
        let frames = timeStamps.count
        var out = [Float](repeating: 0, count: frames)

        // Prealloc
        var window = [Float](repeating: 0, count: N)
        vDSP_hann_window(&window, vDSP_Length(N), Int32(vDSP_HANN_NORM))
        var tmp = [Float](repeating: 0, count: N)

        let minPeriod = Int(sr / 800)     // 800 Hz
        let maxPeriod = Int(sr / 120)     // 120 Hz

        for i in stride(from: 0, to: frames, by: step) {
            let off = i * H
            guard off + N <= samples.count else { break }

            // Copy once, window in place
            tmp.withUnsafeMutableBufferPointer { dst in
                _ = dst.initialize(from: samples[off..<off+N])
            }
            vDSP_vmul(tmp, 1, window, 1, &tmp, 1, vDSP_Length(N))

            // Energy gate
            var energy: Float = 0
            vDSP_svesq(tmp, 1, &energy, vDSP_Length(N))
            if energy < 1e-4 {
                out[i] = 0
                continue
            }

            // Autocorr via vDSP (naïve loop replaced)
            var ac = [Float](repeating: 0, count: maxPeriod+1)
            // ac[0] = energy; compute lags in [minPeriod, maxPeriod]
            tmp.withUnsafeBufferPointer { tmpPtr in
                for p in minPeriod...maxPeriod {
                    var dot: Float = 0
                    vDSP_dotpr(tmpPtr.baseAddress!, 1, tmpPtr.baseAddress!.advanced(by: p), 1, &dot, vDSP_Length(N - p))
                    ac[p] = dot / energy // normalized
                }
            }

            // Pick peak
            let best = ac[minPeriod...maxPeriod].max() ?? 0
            out[i] = min(max(best, 0), 1)

            // Fill skipped frames with small decay (looks continuous)
            if i > 0 {
                let prev = out[i - step]
                let stepf = Float(step)
                let k: Float = 0.6 // decay toward current over step
                for j in 1..<step {
                    let t = Float(j)/stepf
                    out[i - step + j] = prev * (1 - k*t) + out[i]*k*t
                }
            }
        }
        // Backfill tail if needed
        if frames >= step { 
            for j in frames - (frames % step)..<frames { 
                out[j] = out[frames - (frames % step) - 1] 
            } 
        }
        return out
    }
    
    private func computeMidbandEnergy(samples: [Float], timeStamps: [Double]) -> [Float] {
        var midbandEnergy: [Float] = []
        
        for i in 0..<timeStamps.count {
            let offset = i * config.hopSize
            guard offset + config.frameSize < samples.count else { break }
            
            let frame = Array(samples[offset..<(offset + config.frameSize)])
            
            // Apply Hann window and FFT
            var window = [Float](repeating: 0, count: config.frameSize)
            vDSP_hann_window(&window, vDSP_Length(config.frameSize), Int32(vDSP_HANN_NORM))
            
            var windowed = [Float](repeating: 0, count: config.frameSize)
            vDSP_vmul(frame, 1, window, 1, &windowed, 1, vDSP_Length(config.frameSize))
            
            var realParts = windowed
            var imagParts = [Float](repeating: 0, count: config.frameSize)
            
            guard let setup = fftSetup else { continue }
            vDSP_DFT_Execute(setup, realParts, imagParts, &realParts, &imagParts)
            
            // Compute magnitudes
            var magnitudes = [Float](repeating: 0, count: config.frameSize / 2)
            for j in 0..<magnitudes.count {
                magnitudes[j] = sqrt(realParts[j] * realParts[j] + imagParts[j] * imagParts[j])
            }
            
            // Sum 1-4 kHz band
            let binWidth = config.sampleRate / Float(config.frameSize)
            let startBin = Int(1000 / binWidth)
            let endBin = Int(4000 / binWidth)
            let energy = magnitudes[startBin..<min(endBin, magnitudes.count)].reduce(0, +)
            midbandEnergy.append(energy)
        }
        
        // Normalize
        if let maxEnergy = midbandEnergy.max(), maxEnergy > 0 {
            midbandEnergy = midbandEnergy.map { $0 / maxEnergy }
        }
        
        return midbandEnergy
    }
    
    private func computeEnergySlope(rmsEnvelope: [Float]) -> [Float] {
        var slopes: [Float] = []
        let windowSize = 20  // frames
        
        for i in windowSize..<(rmsEnvelope.count - windowSize) {
            let window = Array(rmsEnvelope[i-windowSize..<i+windowSize])
            let slope = linearRegression(window: window)
            slopes.append(slope)
        }
        
        // Pad with zeros
        let paddedSlopes = Array(repeating: Float(0), count: windowSize) + slopes + Array(repeating: Float(0), count: windowSize)
        return paddedSlopes
    }
    
    private func linearRegression(window: [Float]) -> Float {
        let n = Float(window.count)
        let xMean = (n - 1) / 2
        let yMean = window.reduce(0, +) / n
        
        var numerator: Float = 0
        var denominator: Float = 0
        
        for i in 0..<window.count {
            let x = Float(i) - xMean
            let y = window[i] - yMean
            numerator += x * y
            denominator += x * x
        }
        
        return denominator > 0 ? numerator / denominator : 0
    }
    
    // Compute onset density from detected onsets (not frame times)
    private func onsetDensity(onsets: [BeatEvent], samplingTimes: [Double]) -> [Float] {
        var out = [Float](repeating: 0, count: samplingTimes.count)
        let win = 1.0  // 1 second window
        var j0 = 0
        
        for (i, t) in samplingTimes.enumerated() {
            // Move j0 forward to start of window
            while j0 < onsets.count && onsets[j0].t < t - win {
                j0 += 1
            }
            
            // Count onsets in [t-win, t+win]
            var j = j0
            var c = 0
            while j < onsets.count && onsets[j].t <= t + win {
                c += 1
                j += 1
            }
            
            out[i] = Float(c) / Float(2 * win)  // events per second
        }
        
        return out
    }
    
    private func computeSpectralCentroid(samples: [Float], timeStamps: [Double]) -> [Float] {
        var centroids: [Float] = []
        
        for i in 0..<timeStamps.count {
            let offset = i * config.hopSize
            guard offset + config.frameSize < samples.count else { break }
            
            let frame = Array(samples[offset..<(offset + config.frameSize)])
            
            // Apply Hann window and FFT
            var window = [Float](repeating: 0, count: config.frameSize)
            vDSP_hann_window(&window, vDSP_Length(config.frameSize), Int32(vDSP_HANN_NORM))
            
            var windowed = [Float](repeating: 0, count: config.frameSize)
            vDSP_vmul(frame, 1, window, 1, &windowed, 1, vDSP_Length(config.frameSize))
            
            // FFT with separate in/out buffers (prevents corruption)
            var inReal = windowed
            var inImag = [Float](repeating: 0, count: config.frameSize)
            var outReal = [Float](repeating: 0, count: config.frameSize)
            var outImag = [Float](repeating: 0, count: config.frameSize)
            
            guard let setup = fftSetup else { continue }
            vDSP_DFT_Execute(setup, inReal, inImag, &outReal, &outImag)
            
            // Compute magnitudes from output buffers
            var magnitudes = [Float](repeating: 0, count: config.frameSize / 2)
            for j in 0..<magnitudes.count {
                magnitudes[j] = sqrt(outReal[j] * outReal[j] + outImag[j] * outImag[j])
            }
            
            // Compute spectral centroid
            let binWidth = config.sampleRate / Float(config.frameSize)
            var weightedSum: Float = 0
            var magnitudeSum: Float = 0
            
            for j in 0..<magnitudes.count {
                let freq = Float(j) * binWidth
                weightedSum += freq * magnitudes[j]
                magnitudeSum += magnitudes[j]
            }
            
            let centroid = magnitudeSum > 0 ? weightedSum / magnitudeSum : 0
            centroids.append(centroid)
        }
        
        // Normalize to 0-1 range
        if let maxCentroid = centroids.max(), maxCentroid > 0 {
            centroids = centroids.map { $0 / maxCentroid }
        }
        
        return centroids
    }
    
    // MARK: - New Detection Methods
    
    private func detectChorus(chromagram: [[Float]], rmsEnvelope: [Float], timeStamps: [Double]) -> [BeatEvent] {
        var events: [BeatEvent] = []
        let windowSize = 8  // beats
        let similarityThreshold: Float = 0.55  // Lowered from 0.75 for more sensitivity
        
        for i in windowSize..<(chromagram.count - windowSize) {
            let window = Array(chromagram[i-windowSize..<i+windowSize])
            
            // Compute self-similarity matrix
            var maxSimilarity: Float = 0
            for j in 0..<windowSize {
                for k in (j+1)..<windowSize {
                    let similarity = cosineSimilarity(window[j], window[k])
                    maxSimilarity = max(maxSimilarity, similarity)
                }
            }
            
            // High similarity + high RMS = chorus (lowered RMS threshold too)
            if maxSimilarity > similarityThreshold && rmsEnvelope[i] > -25 {  // Lowered from -20
                events.append(createBeatEvent(t: timeStamps[i], kind: .chorusStart, strength: maxSimilarity))
            }
        }
        
        return events
    }
    
    private func detectSectionBoundaries(chromagram: [[Float]], timeStamps: [Double]) -> [BeatEvent] {
        var events: [BeatEvent] = []
        
        for i in 1..<chromagram.count {
            let novelty = chromaNovelty(chromagram[i-1], chromagram[i])
            let threshold = 1.4 * localMean(chromagram, around: i, window: 20)
            
            if novelty > threshold {
                events.append(createBeatEvent(t: timeStamps[i], kind: .sectionBoundary, strength: min(novelty / threshold, 1.0)))
            }
        }
        
        return events
    }
    
    private func detectVocals(pitchConfidence: [Float], midbandEnergy: [Float], timeStamps: [Double]) -> [BeatEvent] {
        var events: [BeatEvent] = []
        let pitchThreshold: Float = 0.5  // Lowered for more sensitivity
        let energyThreshold: Float = 0.3
        
        var inVocalSection = false
        var vocalStartTime: Double = 0
        
        for i in 0..<pitchConfidence.count {
            let isVocal = pitchConfidence[i] > pitchThreshold && midbandEnergy[i] > energyThreshold
            
            if isVocal && !inVocalSection {
                // Vocal phrase start
                events.append(createBeatEvent(t: timeStamps[i], kind: .vocalIn, strength: pitchConfidence[i]))
                inVocalSection = true
                vocalStartTime = timeStamps[i]
            } else if !isVocal && inVocalSection {
                // Vocal phrase end
                inVocalSection = false
            }
        }
        
        return events
    }
    
    private func detectBuildUps(energySlope: [Float], onsetDensity: [Float], timeStamps: [Double]) -> [BeatEvent] {
        var events: [BeatEvent] = []
        let slopeThreshold: Float = 0.08
        let densityThreshold: Float = 2.0  // events/sec
        
        for i in 0..<energySlope.count {
            if energySlope[i] > slopeThreshold && onsetDensity[i] > densityThreshold {
                events.append(createBeatEvent(t: timeStamps[i], kind: .buildUp, strength: min(energySlope[i] / slopeThreshold, 1.0)))
            }
        }
        
        return events
    }
    
    private func detectBreakdowns(rmsEnvelope: [Float], timeStamps: [Double]) -> [BeatEvent] {
        var events: [BeatEvent] = []
        let dropThreshold: Float = 6.0  // dB
        let minDuration = 0.4  // seconds
        let maxDuration = 0.8  // seconds
        
        var inBreakdown = false
        var breakdownStart: Int = 0
        
        for i in 1..<rmsEnvelope.count {
            let drop = rmsEnvelope[i-1] - rmsEnvelope[i]
            
            if !inBreakdown && drop > dropThreshold {
                inBreakdown = true
                breakdownStart = i
            } else if inBreakdown {
                let duration = timeStamps[i] - timeStamps[breakdownStart]
                if duration > maxDuration || drop < -dropThreshold {
                    if duration >= minDuration {
                        let strength = min(drop / dropThreshold, 1.0)
                        events.append(createBeatEvent(t: timeStamps[breakdownStart], kind: .breakdown, strength: strength))
                    }
                    inBreakdown = false
                }
            }
        }
        
        return events
    }
    
    private func detectBrightnessSpikes(spectralCentroid: [Float], timeStamps: [Double]) -> [BeatEvent] {
        var events: [BeatEvent] = []
        let windowFrames = 20
        
        for i in windowFrames..<(spectralCentroid.count - windowFrames) {
            let localMean = Array(spectralCentroid[i-windowFrames..<i+windowFrames]).reduce(0, +) / Float(windowFrames * 2)
            let threshold = localMean * 1.5
            
            if spectralCentroid[i] > threshold {
                let isLocalMax = (i == 0 || spectralCentroid[i] > spectralCentroid[i-1]) &&
                                 (i == spectralCentroid.count - 1 || spectralCentroid[i] > spectralCentroid[i+1])
                if isLocalMax {
                    let strength = min((spectralCentroid[i] - threshold) / (threshold * 0.5), 1.0)
                    events.append(createBeatEvent(t: timeStamps[i], kind: .brightnessSpike, strength: strength))
                }
            }
        }
        
        return events
    }
    
    private func detectSustains(onsetDensity: [Float], rmsEnvelope: [Float], timeStamps: [Double]) -> [BeatEvent] {
        var events: [BeatEvent] = []
        let maxDensity: Float = 2.0  // events/sec
        let maxVariance: Float = 0.15
        
        let windowSize = 30  // frames
        
        for i in windowSize..<(onsetDensity.count - windowSize) {
            let densityWindow = Array(onsetDensity[i-windowSize..<i+windowSize])
            let rmsWindow = Array(rmsEnvelope[i-windowSize..<i+windowSize])
            
            let avgDensity = densityWindow.reduce(0, +) / Float(windowSize)
            let avgRms = rmsWindow.reduce(0, +) / Float(windowSize)
            let rmsVariance = rmsWindow.map { pow($0 - avgRms, 2) }.reduce(0, +) / Float(windowSize)
            
            if avgDensity < maxDensity && rmsVariance < maxVariance {
                events.append(createBeatEvent(t: timeStamps[i], kind: .sustain, strength: min(1.0 - avgDensity / maxDensity, 1.0)))
            }
        }
        
        return events
    }
    
    // MARK: - Helper Functions
    
    // Log-pitch chroma index mapping (C4 = 261.6256 Hz as reference)
    @inline(__always)
    private func chromaIndex(for freq: Float) -> Int? {
        guard freq >= 32, freq <= 5000 else { return nil }
        // Compute pitch class: 12 * log2(f / C4)
        let pc = Int(round(12 * log2(freq / 261.6256))) % 12
        return (pc + 12) % 12  // Ensure positive
    }
    
    private func cosineSimilarity(_ a: [Float], _ b: [Float]) -> Float {
        guard a.count == b.count else { return 0 }
        
        var dotProduct: Float = 0
        var normA: Float = 0
        var normB: Float = 0
        
        for i in 0..<a.count {
            dotProduct += a[i] * b[i]
            normA += a[i] * a[i]
            normB += b[i] * b[i]
        }
        
        let denominator = sqrt(normA) * sqrt(normB)
        return denominator > 0 ? dotProduct / denominator : 0
    }
    
    private func chromaNovelty(_ prev: [Float], _ curr: [Float]) -> Float {
        guard prev.count == curr.count else { return 0 }
        
        var novelty: Float = 0
        for i in 0..<prev.count {
            novelty += abs(curr[i] - prev[i])
        }
        return novelty / Float(prev.count)
    }
    
    private func localMean(_ array: [[Float]], around index: Int, window: Int) -> Float {
        let start = max(0, index - window/2)
        let end = min(array.count, index + window/2)
        
        var total: Float = 0
        var count = 0
        
        for i in start..<end {
            total += array[i].reduce(0, +)
            count += array[i].count
        }
        
        return count > 0 ? total / Float(count) : 0
    }
    
    // MARK: - BPM Detection
    
    private func cleanedOnsetEnvelope(_ flux: [Float]) -> [Float] {
        guard flux.count > 2 else { return flux }
        
        // High-pass via 1st-order diff
        var diff = [Float](repeating: 0, count: flux.count)
        vDSP_vsub(Array(flux.dropLast()), 1, Array(flux.dropFirst()), 1, &diff, 1, vDSP_Length(flux.count-1))
        diff.insert(0, at: 0)
        
        // Half-wave rectify
        var zero: Float = 0
        vDSP_vthres(diff, 1, &zero, &diff, 1, vDSP_Length(diff.count))
        
        // Smooth ~120ms
        let win = max(1, Int(0.12 * (Float(config.sampleRate)/Float(config.hopSize))))
        var kernel = [Float](repeating: 1.0/Float(win), count: win)
        var smoothed = [Float](repeating: 0, count: diff.count)
        vDSP_conv(diff, 1, kernel, 1, &smoothed, 1, vDSP_Length(diff.count), vDSP_Length(win))
        
        // Normalize 0..1
        if let mx = smoothed.max(), mx > 0 { 
            vDSP_vsdiv(smoothed, 1, [mx], &smoothed, 1, vDSP_Length(smoothed.count)) 
        }
        return smoothed
    }
    
    private func estimateBPM(onsetEnv x: [Float]) -> (bpm: Float, confidence: Float) {
        guard x.count > 256 else { return (120, 0) }
        
        // Remove mean
        var xz = x
        var mean: Float = 0
        vDSP_meanv(x, 1, &mean, vDSP_Length(x.count))
        vDSP_vsadd(x, 1, [-mean], &xz, 1, vDSP_Length(x.count))
        
        // Autocorr lags for 70..180 BPM
        let minBPM: Float = 70, maxBPM: Float = 180
        let hopHz = config.sampleRate / Float(config.hopSize)
        let minLag = Int(round(hopHz * 60 / maxBPM))
        let maxLag = Int(round(hopHz * 60 / minBPM))
        
        var bestLag = minLag, bestVal: Float = 0
        var norm: Float = 0
        vDSP_svesq(xz, 1, &norm, vDSP_Length(xz.count))
        norm = max(norm, 1e-6)
        
        for lag in minLag...maxLag {
            let n = xz.count - lag
            guard n > 32 else { continue }
            var dot: Float = 0
            vDSP_dotpr(xz, 1, Array(xz.dropFirst(lag)), 1, &dot, vDSP_Length(n))
            let val = dot / norm
            if val > bestVal { bestVal = val; bestLag = lag }
        }
        
        // Handle octave ambiguity
        func ac(_ lag: Int) -> Float {
            guard lag < xz.count else { return 0 }
            let n = xz.count - lag
            var dot: Float = 0
            vDSP_dotpr(xz, 1, Array(xz.dropFirst(lag)), 1, &dot, vDSP_Length(n))
            return dot / norm
        }
        
        let lagHalf = bestLag * 2 <= maxLag ? bestLag * 2 : bestLag
        let lagDouble = bestLag / 2 >= minLag ? bestLag / 2 : bestLag
        
        let cBest = bestVal, cHalf = ac(lagHalf), cDouble = ac(lagDouble)
        var chosenLag = bestLag; var conf = cBest
        if cHalf > cBest * 1.05 { chosenLag = lagHalf; conf = cHalf }
        if cDouble > conf * 1.05 { chosenLag = lagDouble; conf = cDouble }
        
        let bpm = 60 * hopHz / Float(chosenLag)
        return (min(max(bpm, 70), 180), min(max(conf, 0), 1))
    }
    
    func beatGrid(startAt t0: Double, bpm: Float, until t1: Double) -> [Double] {
        let beat = 60.0 / Double(bpm)
        var t = t0
        var out: [Double] = []
        while t < t1 { 
            out.append(t)
            t += beat 
        }
        return out
    }
    
    private func createBeatEvent(t: Double, kind: BeatKind, strength: Float, frequencyBands: [Float: Float] = [:]) -> BeatEvent {
        var metadata: [String: Any] = [
            "bpm": telemetry.estimatedBPM,
            "bpmConfidence": telemetry.bpmConfidence,
            "vibeScores": telemetry.vibeScores
        ]
        
        // Add frequency band data if available
        if !frequencyBands.isEmpty {
            let bandsDict: [String: Float] = [
                "mid1": frequencyBands[250] ?? 0,
                "mid2": frequencyBands[500] ?? 0,
                "mid3": frequencyBands[1000] ?? 0,
                "high1": frequencyBands[2000] ?? 0,
                "high2": frequencyBands[4000] ?? 0,
                "high3": frequencyBands[8000] ?? 0
            ]
            metadata["frequencyBands"] = bandsDict
            
            // DEBUG: Log bands being attached to events
            if kind == .bass {
                print("🎼 ATTACHING BANDS to bass event: mid1=\(String(format: "%.3f", bandsDict["mid1"] ?? -1)) mid2=\(String(format: "%.3f", bandsDict["mid2"] ?? -1)) mid3=\(String(format: "%.3f", bandsDict["mid3"] ?? -1))")
            }
        } else {
            print("⚠️ createBeatEvent: frequencyBands dictionary is EMPTY for \(kind.rawValue) event!")
        }
        return BeatEvent(t: t, kind: kind, strength: strength, metadata: metadata)
    }
    
    // MARK: - Telemetry
    
    private func printTelemetry() {
        print("\n📊 BeatAnalyzer Telemetry Report (30s interval):")
        print("   ┌─────────────────────────────────────────┐")
        print("   │ Event Density (events/min):             │")
        
        let sortedEvents = telemetry.eventDensity.sorted { $0.value > $1.value }
        for (kind, density) in sortedEvents {
            let icon = getEventIcon(kind)
            print("   │ \(icon) \(String(format: "%8.1f", density))/min \(kind.rawValue.padding(toLength: 15, withPad: " ", startingAt: 0)) │")
        }
        
        if !telemetry.chorusDurations.isEmpty {
            let avgChorus = telemetry.chorusDurations.reduce(0, +) / Double(telemetry.chorusDurations.count)
            print("   │ 🎵 Avg chorus duration: \(String(format: "%6.1f", avgChorus))s (\(telemetry.chorusDurations.count) sections) │")
        }
        
        print("   │ ⚡ Avg trigger skew: \(String(format: "%8.1f", telemetry.triggerSkew))ms                    │")
        print("   │ 🚫 Dropped FX (cap): \(String(format: "%8d", telemetry.droppedFXCount))                    │")
        print("   │ 📈 Total events: \(String(format: "%8d", telemetry.totalEvents))                    │")
        print("   │ ⏱️  Analysis time: \(String(format: "%6.3f", telemetry.analysisTime))s                    │")
        print("   └─────────────────────────────────────────┘\n")
        
        // Reset telemetry for next interval
        telemetry.reset()
    }
    
    private func getEventIcon(_ kind: BeatKind) -> String {
        switch kind {
        case .onset: return "🎯"
        case .bass: return "🔊"
        case .drop: return "💥"
        case .chorusStart: return "🎵"
        case .chorusEnd: return "🎶"
        case .sectionBoundary: return "📐"
        case .vocalIn: return "🎤"
        case .vocalPhrase: return "🎙️"
        case .buildUp: return "📈"
        case .breakdown: return "📉"
        case .brightnessSpike: return "✨"
        case .sustain: return "🔄"
        }
    }
    
    func updateTelemetry(droppedFX: Int, triggerSkew: Double) {
        telemetry.droppedFXCount = droppedFX
        telemetry.triggerSkew = triggerSkew
    }
}
