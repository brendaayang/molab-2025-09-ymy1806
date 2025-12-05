import Foundation

struct ComfortSong: Identifiable {
    var id: UUID
    var fileName: String
    var title: String
    var artist: String?
    var duration: TimeInterval
    var videoFileName: String?
    var thumbnailFileName: String?
    var mediaItem: MediaItem?
    
    init(id: UUID = UUID(), fileName: String, title: String, artist: String? = nil, duration: TimeInterval = 0, videoFileName: String? = nil, thumbnailFileName: String? = nil, mediaItem: MediaItem? = nil) {
        self.id = id
        self.fileName = fileName
        self.title = title
        self.artist = artist
        self.duration = duration
        self.videoFileName = videoFileName
        self.thumbnailFileName = thumbnailFileName
        self.mediaItem = mediaItem
    }
    
    var hasVideo: Bool {
        return videoFileName != nil || mediaItem?.hasVideo == true
    }
}

enum AudioEffect: String, Codable, CaseIterable {
    case normal = "normal"
    case slowedReverb = "slowed + reverb"
    case nightcore = "nightcore"
    
    var displayName: String {
        return self.rawValue
    }
}

