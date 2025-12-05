//
//  PantryListViewModel.swift
//  Flavorly
//
//  Created by Brenda Yang on 10/18/25.
//

import Foundation
import Combine

final class PantryListViewModel: ObservableObject {
    @Published var pantryItems: [PantryItem] = []
    @Published var items: [PantryItem] = []
    @Published var filterCategory: PantryCategory?
    @Published var showingAddItem = false
    @Published var showLowStockOnly = false
    @Published var showExpiringOnly = false
    
    private let pantryService: PantryServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    
    init(pantryService: PantryServiceProtocol) {
        self.pantryService = pantryService
        
        pantryService.pantryItems
            .sink { [weak self] items in
                self?.pantryItems = items
                self?.items = items
            }
            .store(in: &cancellables)
    }
    
    var filteredItems: [PantryItem] {
        var items = pantryItems
        
        if let category = filterCategory {
            items = items.filter { $0.category == category }
        }
        
        if showLowStockOnly {
            items = items.filter { $0.isLowStock }
        }
        
        if showExpiringOnly {
            items = items.filter { $0.isExpiringSoon || $0.isExpired }
        }
        
        return items.sorted { $0.name < $1.name }
    }
    
    var lowStockCount: Int {
        return pantryService.getLowStockItems().count
    }
    
    var expiringCount: Int {
        return pantryService.getExpiringItems().count
    }
    
    func addItem(
        name: String,
        quantity: Double,
        unit: String,
        category: PantryCategory,
        expirationDate: Date?,
        lowStockThreshold: Double?,
        notes: String
    ) {
        let item = PantryItem(
            name: name,
            quantity: quantity,
            unit: unit,
            category: category,
            expirationDate: expirationDate,
            lowStockThreshold: lowStockThreshold,
            notes: notes
        )
        pantryService.addItem(item)
    }
    
    func updateItem(_ item: PantryItem) {
        pantryService.updateItem(item)
    }
    
    func deleteItem(id: UUID) {
        pantryService.deleteItem(id: id)
    }
    
    func adjustQuantity(item: PantryItem, by amount: Double) {
        var updatedItem = item
        updatedItem.quantity = max(0, item.quantity + amount)
        updatedItem.lastUpdated = Date()
        
        if updatedItem.quantity == 0 {
            // Remove item if quantity reaches 0
            pantryService.deleteItem(id: updatedItem.id)
        } else {
            pantryService.updateItem(updatedItem)
        }
    }
    
    func useItem(id: UUID) {
        // Find the item
        guard let item = pantryItems.first(where: { $0.id == id }) else { return }
        
        // Decrement by 1
        adjustQuantity(item: item, by: -1)
    }
}

