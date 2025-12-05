//
//  StoryPreviewView.swift
//  Flavorly
//
//  Created by Brenda Yang on 10/18/25.
//

import SwiftUI
import Photos

struct UIImageViewWrapper: UIViewRepresentable {
    let uiImage: UIImage
    
    func makeUIView(context: Context) -> UIImageView {
        let imageView = UIImageView(image: uiImage)
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = .black
        print("🖼️ UIImageView created with image: \(uiImage.size)")
        return imageView
    }
    
    func updateUIView(_ uiView: UIImageView, context: Context) {
        uiView.image = uiImage
        print("🔄 UIImageView updated with image: \(uiImage.size)")
    }
}

struct StoryPreviewView: View {
    let image: UIImage
    let onShare: () -> Void
    let onDismiss: () -> Void
    @EnvironmentObject var theme: Theme
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    @State private var showingSaveConfirmation = false
    
    init(image: UIImage, onShare: @escaping () -> Void, onDismiss: @escaping () -> Void) {
        self.image = image
        self.onShare = onShare
        self.onDismiss = onDismiss
        print("🖼️ StoryPreviewView init with image size: \(image.size)")
    }
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Story preview with pinch to zoom - using UIImageView for direct rendering
                UIImageViewWrapper(uiImage: image)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .scaleEffect(scale)
                    .gesture(
                        MagnificationGesture()
                            .onChanged { value in
                                scale = lastScale * value
                            }
                            .onEnded { _ in
                                lastScale = scale
                                // Reset if zoomed out too much
                                if scale < 1.0 {
                                    withAnimation(.spring()) {
                                        scale = 1.0
                                        lastScale = 1.0
                                    }
                                }
                            }
                    )
                    .clipped()
                
                // Action buttons
                VStack(spacing: 16) {
                    HStack(spacing: 16) {
                        Button {
                            onDismiss()
                        } label: {
                            HStack {
                                Image(systemName: "xmark")
                                Text("close")
                                    .font(Theme.Fonts.bakeryBody)
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 12)
                            .background(Color.gray.opacity(0.3))
                            .cornerRadius(20)
                        }
                        
                        Button {
                            saveToPhotos()
                        } label: {
                            HStack {
                                Image(systemName: "arrow.down.circle")
                                Text("save")
                                    .font(Theme.Fonts.bakeryBody)
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 12)
                            .background(Color.purple.opacity(0.6))
                            .cornerRadius(20)
                        }
                        
                        Button {
                            onShare()
                        } label: {
                            HStack {
                                Image(systemName: "square.and.arrow.up")
                                Text("share")
                                    .font(Theme.Fonts.bakeryBody)
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 12)
                            .background(
                                LinearGradient(
                                    colors: [Color.flavorlyRose, Color.flavorlyPink],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(20)
                            .shadow(color: .flavorlyPink.opacity(0.5), radius: 10, x: 0, y: 5)
                        }
                    }
                    
                    if showingSaveConfirmation {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                            Text("saved to photos!")
                                .font(Theme.Fonts.bakeryCaption)
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.black.opacity(0.7))
                        .cornerRadius(15)
                        .transition(.scale.combined(with: .opacity))
                    }
                }
                .padding(.vertical, 20)
                .padding(.bottom, 20)
            }
        }
    }
    
    private func saveToPhotos() {
        PHPhotoLibrary.requestAuthorization { status in
            guard status == .authorized else { return }
            
            PHPhotoLibrary.shared().performChanges({
                PHAssetCreationRequest.creationRequestForAsset(from: image)
            }) { success, error in
                DispatchQueue.main.async {
                    if success {
                        withAnimation {
                            showingSaveConfirmation = true
                        }
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            withAnimation {
                                showingSaveConfirmation = false
                            }
                        }
                    }
                }
            }
        }
    }
}

