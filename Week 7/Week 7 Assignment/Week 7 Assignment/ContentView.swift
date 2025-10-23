import SwiftUI
import PhotosUI
import UIKit

struct ContentView: View {
    @State private var photoItem: PhotosPickerItem? = nil
    @State private var originalImage: UIImage? = nil
    @State private var processedImage: UIImage? = nil

    // Editing parameters
    @State private var brightness: Double = 0.0   // -1..1
    @State private var contrast: Double = 1.0     // 0..4
    @State private var sepiaOn: Bool = false
    @State private var rotationSteps: Int = 0    // 0..3 (90° increments)
    @State private var cropSquare: Bool = false

    var body: some View {
        NavigationStack {
            VStack {
                // Picker
                PhotosPicker(selection: $photoItem, matching: .images, photoLibrary: .shared()) {
                    Text("Select Photo")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue.opacity(0.85))
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .padding(.horizontal)

                // Display
                Group {
                    if let ui = processedImage {
                        GeometryReader { geo in
                            Image(uiImage: ui)
                                .resizable()
                                .scaledToFit()
                                .frame(maxWidth: geo.size.width, maxHeight: geo.size.height)
                        }
                    } else {
                        Rectangle()
                            .fill(Color.gray.opacity(0.15))
                            .overlay(Text("No image selected").foregroundColor(.secondary))
                    }
                }
                .frame(height: 360)
                .padding()

                // Controls
                VStack(spacing: 12) {
                    HStack {
                        Text("Brightness")
                        Slider(value: $brightness, in: -1.0...1.0) {
                            Text("Brightness")
                        } minimumValueLabel: { Text("-1") } maximumValueLabel: { Text("+1") }
                        .onChange(of: brightness) { _ in applyProcessing() }
                    }

                    HStack {
                        Text("Contrast")
                        Slider(value: $contrast, in: 0.25...4.0) {
                            Text("Contrast")
                        } minimumValueLabel: { Text("0.25") } maximumValueLabel: { Text("4") }
                        .onChange(of: contrast) { _ in applyProcessing() }
                    }

                    Toggle("Sepia Tone", isOn: $sepiaOn)
                        .onChange(of: sepiaOn) { _ in applyProcessing() }

                    HStack {
                        Button(action: {
                            rotationSteps = (rotationSteps + 1) % 4
                            applyProcessing()
                        }) {
                            Label("Rotate 90°", systemImage: "rotate.right")
                        }
                        Spacer()
                        Toggle("Crop square", isOn: $cropSquare)
                            .onChange(of: cropSquare) { _ in applyProcessing() }
                    }

                    HStack {
                        Button(action: revertToOriginal) {
                            Text("Revert")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color(.systemGray5))
                                .cornerRadius(8)
                        }
                        Button(action: saveToPhotos) {
                            Text("Save")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.green)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                    }
                }
                .padding(.horizontal)
            }
            .navigationTitle("Photo Editor")
            .onChange(of: photoItem) { _ in
                loadSelectedImage()
            }
        }
    }

    // MARK: - Actions

    @MainActor
    private func loadSelectedImage() {
        guard let item = photoItem else { return }
        Task {
            if let data = try? await item.loadTransferable(type: Data.self),
               let ui = UIImage(data: data) {
                // Use the image as-is to avoid calling an inaccessible fileprivate method.
                originalImage = ui
                resetParams()
                applyProcessing()
            }
        }
    }

    @MainActor
    private func resetParams() {
        brightness = 0
        contrast = 1
        sepiaOn = false
        rotationSteps = 0
        cropSquare = false
    }

    @MainActor
    private func applyProcessing() {
        guard let base = originalImage else { return }
        Task {
            let result = await ImageProcessor.process(
                image: base,
                brightness: Float(brightness),
                contrast: Float(contrast),
                sepia: sepiaOn,
                rotationSteps: rotationSteps,
                cropSquare: cropSquare
            )
            await MainActor.run {
                processedImage = result
            }
        }
    }

    @MainActor
    private func revertToOriginal() {
        processedImage = originalImage
        resetParams()
    }

    @MainActor
    private func saveToPhotos() {
        guard let toSave = processedImage else { return }
        UIImageWriteToSavedPhotosAlbum(toSave, nil, nil, nil)
        // For production: show user feedback (alert/toast) and handle errors via callback selector.
    }
}

// Preview
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
