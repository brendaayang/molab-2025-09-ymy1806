//
//  RecipeMedia.swift
//  Flavorly
//
//  Created by Brenda Yang on 10/18/25.
//

import Foundation

enum MediaType: String, Codable {
    case photo
    case video
}

struct RecipeMedia: Identifiable, Codable, Equatable {
    let id: UUID
    let type: MediaType
    let data: String // Base64 encoded image or video data
    let timestamp: Date
    let caption: String?
    
    init(
        id: UUID = UUID(),
        type: MediaType,
        data: String,
        timestamp: Date = Date(),
        caption: String? = nil
    ) {
        self.id = id
        self.type = type
        self.data = data
        self.timestamp = timestamp
        self.caption = caption
    }
}

