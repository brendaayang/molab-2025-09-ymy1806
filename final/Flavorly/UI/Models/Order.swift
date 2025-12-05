//
//  Order.swift
//  Flavorly
//
//  Created by Brenda Yang on 10/18/25.
//

import Foundation

struct Order: Identifiable, Codable, Equatable {
    let id: UUID
    var customerName: String
    var recipeId: UUID?  // Optional link to recipe
    var itemName: String
    var quantity: Int
    var price: Decimal
    var orderDate: Date
    var fulfillmentDate: Date?
    var status: OrderStatus
    var deliveryMethod: DeliveryMethod
    var deliveryAddress: String
    var customerPhone: String
    var notes: String
    var isPaid: Bool
    var createdAt: Date
    
    init(
        id: UUID = UUID(),
        customerName: String,
        recipeId: UUID? = nil,
        itemName: String,
        quantity: Int = 1,
        price: Decimal,
        orderDate: Date = Date(),
        fulfillmentDate: Date? = nil,
        status: OrderStatus = .pending,
        deliveryMethod: DeliveryMethod = .pickup,
        deliveryAddress: String = "",
        customerPhone: String = "",
        notes: String = "",
        isPaid: Bool = false,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.customerName = customerName
        self.recipeId = recipeId
        self.itemName = itemName
        self.quantity = quantity
        self.price = price
        self.orderDate = orderDate
        self.fulfillmentDate = fulfillmentDate
        self.status = status
        self.deliveryMethod = deliveryMethod
        self.deliveryAddress = deliveryAddress
        self.customerPhone = customerPhone
        self.notes = notes
        self.isPaid = isPaid
        self.createdAt = createdAt
    }
    
    var totalPrice: Decimal {
        price * Decimal(quantity)
    }
}

