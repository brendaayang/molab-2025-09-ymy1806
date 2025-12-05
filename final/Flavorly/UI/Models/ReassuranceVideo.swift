import Foundation

struct ReassuranceVideo: Identifiable, Codable {
    var id: UUID
    var fileName: String
    var title: String
    var thumbnailPath: String?
    var duration: TimeInterval
    var dateAdded: Date
    
    init(id: UUID = UUID(), fileName: String, title: String, thumbnailPath: String? = nil, duration: TimeInterval = 0, dateAdded: Date = Date()) {
        self.id = id
        self.fileName = fileName
        self.title = title
        self.thumbnailPath = thumbnailPath
        self.duration = duration
        self.dateAdded = dateAdded
    }
}

