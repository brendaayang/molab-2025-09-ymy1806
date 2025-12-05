//
//  RecipeProgressSummaryView.swift
//  Flavorly
//
//  Created by Brenda Yang on 9/20/25.
//

import SwiftUI

struct RecipeProgressSummaryView: View {
    let recipe: Recipe
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var theme: Theme
    @State private var generatedStoryImage: UIImage?
    @State private var showingShareSheet = false
    @State private var showingStoryPreview = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.flavorlyCream.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Instagram Story Button
                        if !recipe.progressMedia.isEmpty {
                            // Debug: Test save button
                            Button {
                                if let image = generatedStoryImage {
                                    UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
                                    print("💾 Saved to Photos for testing")
                                }
                            } label: {
                                Text("Debug: Save to Photos")
                                    .font(Theme.Fonts.bakeryCaption)
                                    .foregroundColor(.purple)
                            }
                            .padding(.top, 10)
                            
                            Button {
                                generateInstagramStory()
                            } label: {
                                HStack(spacing: 12) {
                                    Image(systemName: "square.and.arrow.up")
                                        .font(.title3)
                                    Text("create instagram story")
                                        .font(Theme.Fonts.bakeryHeadline)
                                        .fontWeight(.semibold)
                                    
                                    Spacer()
                                    
                                    GIFImage(name: "melody_hearteyes", contentMode: .scaleAspectFit)
                                        .frame(width: 40, height: 40)
                                }
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(
                                    LinearGradient(
                                        colors: [Color.flavorlyRose, Color.flavorlyPink],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .cornerRadius(theme.cornerRadius)
                                .shadow(color: .flavorlyPink.opacity(0.3), radius: 10, x: 0, y: 5)
                            }
                            .padding(.horizontal)
                            .padding(.top, 20)
                        }
                        
                        // Timeline
                        if recipe.progressMedia.isEmpty {
                            VStack(spacing: 16) {
                                GIFImage(name: "melody_working", contentMode: .scaleAspectFit)
                                    .frame(width: 80, height: 80)
                                Text("no progress photos yet")
                                    .font(Theme.Fonts.bakeryBody)
                                    .foregroundColor(.secondary)
                            }
                            .padding(.top, 40)
                        } else {
                            VStack(alignment: .leading, spacing: 0) {
                                Text("timeline")
                                    .font(Theme.Fonts.bakeryHeadline)
                                    .foregroundColor(.flavorlyPinkDark)
                                    .padding(.bottom, 16)
                                
                                ForEach(Array(recipe.progressMedia.enumerated()), id: \.element.id) { index, media in
                                    MediaTimelineItem(media: media, isLast: index == recipe.progressMedia.count - 1)
                                }
                            }
                            .padding()
                            .background(Color.flavorlyWhite)
                            .cornerRadius(theme.cornerRadius)
                            .shadow(color: .flavorlyPink.opacity(0.2), radius: 8, x: 0, y: 4)
                        }
                    }
                    .padding()
                    .padding(.bottom, 40)
                }
            }
            .navigationTitle("summary")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("done") {
                        dismiss()
                    }
                    .font(Theme.Fonts.bakeryBody)
                    .foregroundColor(.flavorlyPink)
                }
            }
            .sheet(isPresented: $showingStoryPreview) {
                if let image = generatedStoryImage {
                    StoryPreviewView(image: image, onShare: {
                        showingStoryPreview = false
                        showingShareSheet = true
                    }, onDismiss: {
                        showingStoryPreview = false
                    })
                    .environmentObject(theme)
                } else {
                    Text("Loading...")
                        .foregroundColor(.white)
                }
            }
            .sheet(isPresented: $showingShareSheet) {
                if let image = generatedStoryImage {
                    ShareSheet(items: [image])
                }
            }
        }
    }
    
    private func generateInstagramStory() {
        print("🎨 Starting story generation with \(recipe.progressMedia.count) photos")
        
        // Generate on background thread to avoid blocking UI
        DispatchQueue.global(qos: .userInitiated).async {
            let image = InstagramStoryGenerator.generateStory(from: recipe.progressMedia, recipeName: recipe.name)
            
            DispatchQueue.main.async {
                if let image = image {
                    print("✅ Story generated successfully: \(image.size)")
                    generatedStoryImage = image
                    showingStoryPreview = true
                } else {
                    print("❌ Failed to generate story")
                }
            }
        }
    }
    
    private var timeSpentText: String {
        guard let first = recipe.progressMedia.first?.timestamp,
              let last = recipe.progressMedia.last?.timestamp else {
            return "0m"
        }
        
        let minutes = Int(last.timeIntervalSince(first) / 60)
        if minutes < 60 {
            return "\(minutes)m"
        } else {
            let hours = minutes / 60
            let mins = minutes % 60
            return "\(hours)h \(mins)m"
        }
    }
}

struct MediaTimelineItem: View {
    let media: RecipeMedia
    let isLast: Bool
    @EnvironmentObject var theme: Theme
    @State private var showFullScreen = false
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            // Timeline indicator
            VStack(spacing: 0) {
                Circle()
                    .fill(Color.flavorlyPink)
                    .frame(width: 12, height: 12)
                
                if !isLast {
                    Rectangle()
                        .fill(Color.flavorlyPink.opacity(0.3))
                        .frame(width: 2)
                }
            }
            
            // Content
            VStack(alignment: .leading, spacing: 8) {
                Text(media.timestamp, style: .time)
                    .font(Theme.Fonts.bakeryCaption)
                    .foregroundColor(.flavorlyPink)
                
                Button {
                    showFullScreen = true
                } label: {
                    if media.type == .photo {
                        if let data = Data(base64Encoded: media.data),
                           let uiImage = UIImage(data: data) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFill()
                                .frame(height: 200)
                                .frame(maxWidth: .infinity)
                                .clipped()
                                .cornerRadius(theme.smallCornerRadius)
                        }
                    } else {
                        ZStack {
                            Color.gray.opacity(0.3)
                                .frame(height: 200)
                                .cornerRadius(theme.smallCornerRadius)
                            
                            VStack(spacing: 8) {
                                Image(systemName: "play.circle.fill")
                                    .font(Theme.Fonts.bakeryTitle)
                                    .foregroundColor(.white)
                                Text("video")
                                    .font(Theme.Fonts.bakeryCaption)
                                    .foregroundColor(.white)
                            }
                        }
                    }
                }
                
                if let caption = media.caption, !caption.isEmpty {
                    Text(caption.lowercased())
                        .font(Theme.Fonts.bakeryBody)
                        .foregroundColor(.primary)
                }
            }
            .padding(.bottom, isLast ? 0 : 20)
        }
        .fullScreenCover(isPresented: $showFullScreen) {
            MediaFullScreenView(media: media)
        }
    }
}

struct MediaFullScreenView: View {
    let media: RecipeMedia
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack {
                HStack {
                    Spacer()
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title)
                            .foregroundColor(.white)
                            .padding()
                    }
                }
                
                Spacer()
                
                if media.type == .photo {
                    if let data = Data(base64Encoded: media.data),
                       let uiImage = UIImage(data: data) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFit()
                    }
                } else {
                    Text("video playback coming soon!")
                        .font(Theme.Fonts.bakeryBody)
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                if let caption = media.caption, !caption.isEmpty {
                    Text(caption)
                        .font(Theme.Fonts.bakeryBody)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.black.opacity(0.7))
                        .cornerRadius(12)
                        .padding()
                }
            }
        }
    }
}

