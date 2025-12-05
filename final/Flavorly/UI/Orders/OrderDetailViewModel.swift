//
//  OrderDetailViewModel.swift
//  Flavorly
//
//  Created by Brenda Yang on 10/18/25.
//

import SwiftUI
import Combine

final class OrderDetailViewModel: Bindable, ViewModel {
    let id = UUID()
    
    private let orderService: OrderServiceProtocol
    
    @Published var order: Order
    @Published var isEditing = false
    
    init(orderService: OrderServiceProtocol) {
        self.orderService = orderService
        self.order = Order(customerName: "", itemName: "", price: 0)
        super.init()
        bind()
    }
    
    func updateOrder(_ updatedOrder: Order) {
        self.order = updatedOrder
        orderService.updateOrder(updatedOrder)
    }
    
    func togglePaidStatus() {
        var updated = order
        updated.isPaid = !updated.isPaid
        updateOrder(updated)
    }
    
    func updateStatus(to status: OrderStatus) {
        var updated = order
        updated.status = status
        updateOrder(updated)
    }
}

