//
//  Recipe.swift
//  Flavorly
//
//  Created by Brenda Yang on 10/18/25.
//

import Foundation

struct Recipe: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String
    var status: RecipeStatus
    var makeDate: Date?
    var notes: String
    var category: String
    var links: [String] // Multiple recipe links
    var createdAt: Date
    var inspirationPhotos: [String] // Array of image data (base64 or file names)
    var progressMedia: [RecipeMedia] // Photos/videos taken while cooking!
    
    init(
        id: UUID = UUID(),
        name: String,
        status: RecipeStatus = .planning,
        makeDate: Date? = nil,
        notes: String = "",
        category: String = "",
        links: [String] = [],
        createdAt: Date = Date(),
        inspirationPhotos: [String] = [],
        progressMedia: [RecipeMedia] = []
    ) {
        self.id = id
        self.name = name
        self.status = status
        self.makeDate = makeDate
        self.notes = notes
        self.category = category
        self.links = links
        self.createdAt = createdAt
        self.inspirationPhotos = inspirationPhotos
        self.progressMedia = progressMedia
    }
}

