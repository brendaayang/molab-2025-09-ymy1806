//
//  OrderServiceProtocol.swift
//  Flavorly
//
//  Created by Brenda Yang on 10/18/25.
//

import Foundation
import Combine

protocol OrderServiceProtocol {
    var orders: AnyPublisher<[Order], Never> { get }
    var totalRevenue: AnyPublisher<Decimal, Never> { get }
    var pendingRevenue: AnyPublisher<Decimal, Never> { get }
    var orderCount: AnyPublisher<Int, Never> { get }
    
    func addOrder(_ order: Order)
    func updateOrder(_ order: Order)
    func deleteOrder(_ order: Order)
    func getOrders() -> [Order]
}

