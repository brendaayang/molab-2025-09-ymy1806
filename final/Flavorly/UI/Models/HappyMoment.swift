import Foundation

struct HappyMoment: Identifiable, Codable {
    var id: UUID
    var imagePath: String
    var caption: String?
    var dateAdded: Date
    var isPreloaded: Bool
    var isLivePhoto: Bool
    var isVideo: Bool
    
    init(id: UUID = UUID(), imagePath: String, caption: String? = nil, dateAdded: Date = Date(), isPreloaded: Bool = false, isLivePhoto: Bool = false, isVideo: Bool = false) {
        self.id = id
        self.imagePath = imagePath
        self.caption = caption
        self.dateAdded = dateAdded
        self.isPreloaded = isPreloaded
        self.isLivePhoto = isLivePhoto
        self.isVideo = isVideo
    }
}

