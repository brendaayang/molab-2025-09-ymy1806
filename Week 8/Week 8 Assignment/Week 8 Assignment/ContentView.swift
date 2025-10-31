import SwiftUI
import PhotosUI
import AVFoundation
import CoreImage
import CoreImage.CIFilterBuiltins
import Photos

struct ContentView: View {
    @State private var pickedItem: PhotosPickerItem?
    @State private var player: AVPlayer?
    @State private var asset: AVAsset?
    @State private var isProcessing = false
    @State private var selectedFilter: VideoFilter = .sepia
    @State private var intensity: Double = 0.8
    @State private var exportProgress: Double = 0
    @State private var statusMessage: String = "Pick a video to begin"
    @State private var showSampleMissingAlert = false
    @State private var showImportDialog = false
    private let sampleVideoNames: [String] = ["Sample", "Sample2", "Sample3"] // add these .mp4 files to your bundle
    private var hasBundledSample: Bool {
        Bundle.main.url(forResource: "Sample", withExtension: "mp4") != nil
    }

    var body: some View {
        VStack(spacing: 16) {
            // Player preview
            VideoPlayerView(player: player)
                .frame(height: 260)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12).stroke(.secondary.opacity(0.2))
                )

            // Picker + controls
            HStack(spacing: 12) {
                Button {
                    showImportDialog = true
                } label: {
                    Label("Import Video", systemImage: "square.and.arrow.down")
                }
                .buttonStyle(.borderedProminent)

                PhotosPicker(selection: $pickedItem, matching: .videos, photoLibrary: .shared()) {
                    Label("From Photos…", systemImage: "photo.on.rectangle")
                }
                .buttonStyle(.bordered)

                Button {
                    player?.seek(to: .zero)
                    player?.play()
                } label: {
                    Label("Play", systemImage: "play.fill")
                }

                Button {
                    player?.pause()
                } label: {
                    Label("Pause", systemImage: "pause.fill")
                }
            }

            // Filter controls
            Picker("Filter", selection: $selectedFilter) {
                ForEach(VideoFilter.allCases, id: \.self) { f in
                    Text(f.displayName).tag(f)
                }
            }
            .pickerStyle(.segmented)

            HStack {
                Text("Intensity")
                Slider(value: $intensity, in: 0...1)
                Text(intensity.formatted(.number.precision(.fractionLength(2))))
                    .monospacedDigit()
                    .frame(width: 52, alignment: .trailing)
            }

            Button {
                Task { await exportTapped() }
            } label: {
                Label("Export to Photos", systemImage: "square.and.arrow.up")
            }
            .buttonStyle(.borderedProminent)
            .disabled(asset == nil || isProcessing)

            // Progress + status
            if isProcessing {
                ProgressView(value: exportProgress)
                    .padding(.horizontal)
            }

            Text(statusMessage)
                .font(.footnote)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Spacer()
        }
        .padding()
        .onChange(of: pickedItem) { _, newValue in
            Task { await loadPickedItem(newValue) }
        }
        .alert("Sample video not found", isPresented: $showSampleMissingAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Add a file named “Sample.mp4” to your app target (Target → Build Phases → Copy Bundle Resources). Then rebuild and try again.")
        }
        .confirmationDialog("Choose a sample video", isPresented: $showImportDialog, titleVisibility: .visible) {
            ForEach(sampleVideoNames, id: \.self) { name in
                Button(name) {
                    loadBundledVideo(named: name, ext: "mp4")
                }
            }
            Button("Cancel", role: .cancel) { }
        }
    }

    // Load selected video into AVAsset/AVPlayer
    private func loadPickedItem(_ item: PhotosPickerItem?) async {
        guard let item else { return }
        statusMessage = "Loading video…"
        do {
            if let url = try await item.loadTransferable(type: URL.self) {
                let asset = AVURLAsset(url: url)
                self.asset = asset
                self.player = AVPlayer(playerItem: AVPlayerItem(asset: asset))
                statusMessage = "Loaded. Choose a filter and export."
            } else {
                statusMessage = "Could not read video URL."
            }
        } catch {
            statusMessage = "Load failed: \(error.localizedDescription)"
        }
    }

    // Load a bundled sample video (e.g., add "Sample.mp4" to your app target)
    private func loadBundledVideo(named: String, ext: String) {
        statusMessage = "Loading sample…"
        if let url = Bundle.main.url(forResource: named, withExtension: ext) {
            let asset = AVURLAsset(url: url)
            self.asset = asset
            self.player = AVPlayer(playerItem: AVPlayerItem(asset: asset))
            statusMessage = "Loaded sample video. Choose a filter and export."
        } else {
            statusMessage = "Sample video not found in app bundle."
            showSampleMissingAlert = true
        }
    }

    private func exportTapped() async {
        guard let asset else { return }
        isProcessing = true
        exportProgress = 0
        statusMessage = "Processing…"

        do {
            let tmpURL = try await VideoProcessor.process(
                asset: asset,
                filter: selectedFilter,
                intensity: intensity
            ) { progress in
                DispatchQueue.main.async {
                    self.exportProgress = progress
                }
            }

            try await saveToPhotos(fileURL: tmpURL)
            statusMessage = "Exported to Photos ✅"
        } catch {
            statusMessage = "Export failed: \(error.localizedDescription)"
        }

        isProcessing = false
        exportProgress = 0
    }

    private func saveToPhotos(fileURL: URL) async throws {
        try await PHPhotoLibrary.shared().performChanges {
            PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: fileURL)
        }
    }
}

// MARK: - Filter Enum

enum VideoFilter: CaseIterable {
    case none, sepia, noir

    var displayName: String {
        switch self {
        case .none:  return "None"
        case .sepia: return "Sepia"
        case .noir:  return "Noir"
        }
    }

    func apply(to image: CIImage, intensity: Double, context: CIContext) -> CIImage {
        switch self {
        case .none:
            return image
        case .sepia:
            let f = CIFilter.sepiaTone()
            f.intensity = Float(intensity)
            f.inputImage = image
            return f.outputImage ?? image
        case .noir:
            let noir = CIFilter.photoEffectNoir()
            noir.inputImage = image
            let output = noir.outputImage ?? image
            if intensity >= 0.999 { return output }
            // Blend original with noir by intensity
            guard let compose = CIFilter(name: "CIBlendWithAlphaMask") else { return output }
            let alpha = CIFilter(name: "CIConstantColorGenerator", parameters: [
                kCIInputColorKey: CIColor(red: 1, green: 1, blue: 1, alpha: CGFloat(intensity))
            ])?.outputImage?.cropped(to: image.extent) ?? image
            compose.setValue(output, forKey: kCIInputImageKey)
            compose.setValue(image, forKey: kCIInputBackgroundImageKey)
            compose.setValue(alpha, forKey: kCIInputMaskImageKey)
            return compose.outputImage ?? output
        }
    }
}

// MARK: - Processing Pipeline

enum VideoProcessor {
    static func process(
        asset: AVAsset,
        filter: VideoFilter,
        intensity: Double,
        progress: @escaping (Double) -> Void
    ) async throws -> URL {

        // Prepare reader
        let reader = try AVAssetReader(asset: asset)
        guard let videoTrack = asset.tracks(withMediaType: .video).first else {
            throw NSError(domain: "VideoProcessor", code: -1, userInfo: [NSLocalizedDescriptionKey: "No video track"])
        }

        let readerSettings: [String: Any] = [
            kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA
        ]
        let readerOutput = AVAssetReaderTrackOutput(track: videoTrack, outputSettings: readerSettings)
        reader.add(readerOutput)

        // Prepare writer
        let outputURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("processed-\(UUID().uuidString).mp4")

        let writer = try AVAssetWriter(outputURL: outputURL, fileType: .mp4)

        let videoSettings: [String: Any] = [
            AVVideoCodecKey: AVVideoCodecType.h264,
            AVVideoWidthKey: videoTrack.naturalSize.width,
            AVVideoHeightKey: videoTrack.naturalSize.height,
            AVVideoCompressionPropertiesKey: [
                AVVideoAverageBitRateKey: max(2_000_000, Int(videoTrack.estimatedDataRate))
            ]
        ]
        let writerInput = AVAssetWriterInput(mediaType: .video, outputSettings: videoSettings)
        writerInput.expectsMediaDataInRealTime = false

        let sourcePixelAttributes: [String: Any] = [
            kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA,
            kCVPixelBufferWidthKey as String: videoTrack.naturalSize.width,
            kCVPixelBufferHeightKey as String: videoTrack.naturalSize.height
        ]
        let adaptor = AVAssetWriterInputPixelBufferAdaptor(assetWriterInput: writerInput,
                                                           sourcePixelBufferAttributes: sourcePixelAttributes)
        writer.add(writerInput)

        // Audio passthrough (optional)
        let audioInputs: [AVAssetWriterInput] = asset.tracks(withMediaType: .audio).compactMap { audioTrack in
            let ai = AVAssetWriterInput(mediaType: .audio, outputSettings: nil)
            ai.expectsMediaDataInRealTime = false
            if writer.canAdd(ai) { writer.add(ai) }
            return ai
        }
        let audioReaders: [AVAssetReaderOutput] = asset.tracks(withMediaType: .audio).compactMap { audioTrack in
            let ro = AVAssetReaderTrackOutput(track: audioTrack, outputSettings: nil)
            if reader.canAdd(ro) { reader.add(ro) }
            return ro
        }

        // CI context
        let ciContext = CIContext()

        // Start reading/writing
        guard reader.startReading(), writer.startWriting() else {
            throw NSError(domain: "VideoProcessor", code: -2, userInfo: [NSLocalizedDescriptionKey: "Could not start IO"])
        }

        let timeRange = CMTimeRange(start: .zero, duration: asset.duration)
        writer.startSession(atSourceTime: timeRange.start)

        // Process video frames
        let totalDuration = asset.duration.seconds
        let nominalFrameRate = max(1.0, Double(videoTrack.nominalFrameRate))
        let frameDuration = CMTime(value: 1, timescale: CMTimeScale(nominalFrameRate))

        writerInput.requestMediaDataWhenReady(on: .global(qos: .userInitiated)) {
            var lastTime = CMTime.zero

            while writerInput.isReadyForMoreMediaData {
                if let sample = readerOutput.copyNextSampleBuffer(),
                   let pb = CMSampleBufferGetImageBuffer(sample) {

                    let time = CMSampleBufferGetPresentationTimeStamp(sample)
                    let ciImage = CIImage(cvImageBuffer: pb)

                    let filtered = filter.apply(to: ciImage, intensity: intensity, context: ciContext)

                    var newPixelBuffer: CVPixelBuffer?
                    let attrs = [
                        kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA,
                        kCVPixelBufferWidthKey as String: Int(videoTrack.naturalSize.width),
                        kCVPixelBufferHeightKey as String: Int(videoTrack.naturalSize.height),
                        kCVPixelBufferIOSurfacePropertiesKey as String: [:]
                    ] as CFDictionary

                    CVPixelBufferCreate(kCFAllocatorDefault,
                                        Int(videoTrack.naturalSize.width),
                                        Int(videoTrack.naturalSize.height),
                                        kCVPixelFormatType_32BGRA,
                                        attrs,
                                        &newPixelBuffer)

                    if let newPB = newPixelBuffer {
                        ciContext.render(filtered, to: newPB)
                        adaptor.append(newPB, withPresentationTime: time)
                    }

                    lastTime = time
                    let progressValue = min(0.99, time.seconds / totalDuration)
                    progress(progressValue)
                } else {
                    writerInput.markAsFinished()
                    progress(1.0)
                    break
                }
            }
        }

        // Audio copy (simple: read packets and pass to writer inputs in order)
        for (idx, aReader) in audioReaders.enumerated() {
            let aInput = audioInputs[idx]
            aInput.requestMediaDataWhenReady(on: .global(qos: .userInitiated)) {
                while aInput.isReadyForMoreMediaData {
                    if let sample = aReader.copyNextSampleBuffer() {
                        aInput.append(sample)
                    } else {
                        aInput.markAsFinished()
                        break
                    }
                }
            }
        }

        // Finish writing (await)
        try await withCheckedThrowingContinuation { (cont: CheckedContinuation<Void, Error>) in
            writer.finishWriting {
                if let error = writer.error {
                    cont.resume(throwing: error)
                } else {
                    cont.resume(returning: ())
                }
            }
        }

        if reader.status == .failed, let err = reader.error {
            throw err
        }
        return outputURL
    }
}

// MARK: - Simple Player View

struct VideoPlayerView: UIViewRepresentable {
    let player: AVPlayer?

    func makeUIView(context: Context) -> PlayerView {
        PlayerView()
    }

    func updateUIView(_ uiView: PlayerView, context: Context) {
        uiView.playerLayer.player = player
    }
}

final class PlayerView: UIView {
    override static var layerClass: AnyClass { AVPlayerLayer.self }
    var playerLayer: AVPlayerLayer { layer as! AVPlayerLayer }
}
