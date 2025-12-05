//
//  OrderService.swift
//  Flavorly
//
//  Created by Brenda Yang on 10/18/25.
//

import Combine
import Foundation

final class OrderService: OrderServiceProtocol {
    private let storageService: StorageServiceProtocol
    private let ordersKey = "orders"
    
    private let _orders: CurrentValueSubject<[Order], Never>
    var orders: AnyPublisher<[Order], Never> {
        _orders.eraseToAnyPublisher()
    }
    
    // Reactive revenue publishers
    var totalRevenue: AnyPublisher<Decimal, Never> {
        _orders
            .map { orders in
                orders
                    .filter { $0.isPaid }
                    .reduce(Decimal(0)) { $0 + $1.totalPrice }
            }
            .eraseToAnyPublisher()
    }
    
    var pendingRevenue: AnyPublisher<Decimal, Never> {
        _orders
            .map { orders in
                orders
                    .filter { !$0.isPaid }
                    .reduce(Decimal(0)) { $0 + $1.totalPrice }
            }
            .eraseToAnyPublisher()
    }
    
    var orderCount: AnyPublisher<Int, Never> {
        _orders
            .map { $0.count }
            .eraseToAnyPublisher()
    }
    
    init(storageService: StorageServiceProtocol) {
        self.storageService = storageService
        
        // Load saved orders or use empty array
        let saved: [Order]? = storageService.getValue(forKey: ordersKey)
        self._orders = CurrentValueSubject(saved ?? [])
    }
    
    func addOrder(_ order: Order) {
        var currentOrders = _orders.value
        currentOrders.append(order)
        save(currentOrders)
    }
    
    func updateOrder(_ order: Order) {
        var currentOrders = _orders.value
        if let index = currentOrders.firstIndex(where: { $0.id == order.id }) {
            currentOrders[index] = order
            save(currentOrders)
        }
    }
    
    func deleteOrder(_ order: Order) {
        var currentOrders = _orders.value
        currentOrders.removeAll { $0.id == order.id }
        save(currentOrders)
    }
    
    func getOrders() -> [Order] {
        _orders.value
    }
    
    private func save(_ orders: [Order]) {
        storageService.setValue(orders, forKey: ordersKey)
        _orders.send(orders)
    }
}

