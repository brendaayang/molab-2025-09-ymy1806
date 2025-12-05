//
//  PantryServiceProtocol.swift
//  Flavorly
//
//  Created by Brenda Yang on 10/18/25.
//

import Foundation
import Combine

protocol PantryServiceProtocol {
    var pantryItems: CurrentValueSubject<[PantryItem], Never> { get }
    
    func addItem(_ item: PantryItem)
    func updateItem(_ item: PantryItem)
    func deleteItem(id: UUID)
    func getLowStockItems() -> [PantryItem]
    func getExpiringItems() -> [PantryItem]
    func getItemsByCategory(_ category: PantryCategory) -> [PantryItem]
}

