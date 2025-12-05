//
//  OrderListViewModel.swift
//  Flavorly
//
//  Created by Brenda Yang on 10/18/25.
//

import SwiftUI
import Combine

final class OrderListViewModel: Bindable, ViewModel {
    let id = UUID()
    
    let orderService: OrderServiceProtocol
    
    @Published var orders: [Order] = []
    @Published var showingAddOrder = false
    @Published var filterStatus: OrderStatus? = nil
    @Published var totalRevenue: Decimal = 0
    @Published var pendingRevenue: Decimal = 0
    @Published var showAchievement: Achievement? = nil
    @Published var showVampireCouple = false
    @Published var showAviArms = false
    
    private let achievementService = AchievementService.shared
    private var achievementCancellable: AnyCancellable?
    
    init(orderService: OrderServiceProtocol) {
        self.orderService = orderService
        super.init()
        
        bind()
        
        // Subscribe to orders
        orderService.orders
            .receive(on: DispatchQueue.main)
            .sink { [weak self] orders in
                self?.orders = orders.sorted { $0.createdAt > $1.createdAt }
                self?.checkAchievements()
            }
            .store(in: &cancelBag)
        
        // Subscribe to REACTIVE revenue updates!
        orderService.totalRevenue
            .receive(on: DispatchQueue.main)
            .assign(to: &$totalRevenue)
        
        orderService.pendingRevenue
            .receive(on: DispatchQueue.main)
            .assign(to: &$pendingRevenue)
        
        // Subscribe to achievements
        achievementCancellable = achievementService.onAchievementUnlocked
            .receive(on: DispatchQueue.main)
            .sink { [weak self] achievement in
                self?.handleAchievement(achievement)
            }
    }
    
    var filteredOrders: [Order] {
        if let status = filterStatus {
            return orders.filter { $0.status == status }
        }
        return orders
    }
    
    func deleteOrder(_ order: Order) {
        orderService.deleteOrder(order)
    }
    
    func addOrder(customerName: String, itemName: String, quantity: Int, price: Decimal, fulfillmentDate: Date?, deliveryMethod: DeliveryMethod, phone: String, address: String, notes: String) {
        let order = Order(
            customerName: customerName,
            itemName: itemName,
            quantity: quantity,
            price: price,
            fulfillmentDate: fulfillmentDate,
            deliveryMethod: deliveryMethod,
            deliveryAddress: address,
            customerPhone: phone,
            notes: notes
        )
        orderService.addOrder(order)
    }
    
    private func checkAchievements() {
        achievementService.checkOrderCount(orders.count)
        achievementService.checkRevenue(totalRevenue)
    }
    
    private func handleAchievement(_ achievement: Achievement) {
        // Show vampire couple for certain achievements
        switch achievement {
        case .firstOrder, .fiveOrders, .tenOrders, .hundredRevenue:
            showVampireCouple = true
        case .thirteenOrders, .twoHundredRevenue:
            showAviArms = true
        default:
            break
        }
    }
}

