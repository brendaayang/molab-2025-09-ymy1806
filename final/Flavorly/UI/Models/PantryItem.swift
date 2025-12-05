//
//  PantryItem.swift
//  Flavorly
//
//  Created by Brenda Yang on 10/18/25.
//

import Foundation

struct PantryItem: Identifiable, Codable {
    var id: UUID
    var name: String
    var quantity: Double
    var unit: String
    var category: PantryCategory
    var expirationDate: Date?
    var lowStockThreshold: Double?
    var lastUpdated: Date
    var notes: String
    
    init(
        id: UUID = UUID(),
        name: String,
        quantity: Double,
        unit: String,
        category: PantryCategory,
        expirationDate: Date? = nil,
        lowStockThreshold: Double? = nil,
        notes: String = ""
    ) {
        self.id = id
        self.name = name
        self.quantity = quantity
        self.unit = unit
        self.category = category
        self.expirationDate = expirationDate
        self.lowStockThreshold = lowStockThreshold
        self.lastUpdated = Date()
        self.notes = notes
    }
    
    var isLowStock: Bool {
        guard let threshold = lowStockThreshold else { return false }
        return quantity <= threshold
    }
    
    var isExpiringSoon: Bool {
        guard let expirationDate = expirationDate else { return false }
        let daysUntilExpiration = Calendar.current.dateComponents([.day], from: Date(), to: expirationDate).day ?? 0
        return daysUntilExpiration <= 7 && daysUntilExpiration >= 0
    }
    
    var isExpired: Bool {
        guard let expirationDate = expirationDate else { return false }
        return expirationDate < Date()
    }
}

enum PantryCategory: String, Codable, CaseIterable {
    case baking = "baking"
    case dairy = "dairy"
    case pantry = "pantry"
    case fresh = "fresh"
    
    var icon: String {
        switch self {
        case .baking:
            return "birthday.cake.fill"
        case .dairy:
            return "drop.fill"
        case .pantry:
            return "cube.fill"
        case .fresh:
            return "leaf.fill"
        }
    }
}

enum PantryUnit: String, CaseIterable {
    case cups = "cups"
    case tablespoons = "tbsp"
    case teaspoons = "tsp"
    case grams = "g"
    case kilograms = "kg"
    case ounces = "oz"
    case pounds = "lb"
    case milliliters = "ml"
    case liters = "l"
    case pieces = "pcs"
    case packages = "pkg"
    
    var displayName: String {
        return rawValue
    }
}

