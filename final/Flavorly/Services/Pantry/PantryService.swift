//
//  PantryService.swift
//  Flavorly
//
//  Created by Brenda Yang on 10/18/25.
//

import Foundation
import Combine

final class PantryService: PantryServiceProtocol {
    private let storageService: StorageServiceProtocol
    private let storageKey = "flavorly.pantry.items"
    
    var pantryItems = CurrentValueSubject<[PantryItem], Never>([])
    
    init(storageService: StorageServiceProtocol) {
        self.storageService = storageService
        loadItems()
    }
    
    func addItem(_ item: PantryItem) {
        var items = pantryItems.value
        items.append(item)
        pantryItems.send(items)
        saveItems()
    }
    
    func updateItem(_ item: PantryItem) {
        var items = pantryItems.value
        if let index = items.firstIndex(where: { $0.id == item.id }) {
            items[index] = item
            pantryItems.send(items)
            saveItems()
        }
    }
    
    func deleteItem(id: UUID) {
        var items = pantryItems.value
        items.removeAll { $0.id == id }
        pantryItems.send(items)
        saveItems()
    }
    
    func getLowStockItems() -> [PantryItem] {
        return pantryItems.value.filter { $0.isLowStock }
    }
    
    func getExpiringItems() -> [PantryItem] {
        return pantryItems.value.filter { $0.isExpiringSoon || $0.isExpired }
    }
    
    func getItemsByCategory(_ category: PantryCategory) -> [PantryItem] {
        return pantryItems.value.filter { $0.category == category }
    }
    
    // MARK: - Private
    
    private func loadItems() {
        if let items: [PantryItem] = storageService.getValue(forKey: storageKey) {
            pantryItems.send(items)
        }
    }
    
    private func saveItems() {
        storageService.setValue(pantryItems.value, forKey: storageKey)
    }
}

