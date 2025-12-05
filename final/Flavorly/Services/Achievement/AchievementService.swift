//
//  AchievementService.swift
//  Flavorly
//
//  Created by Brenda Yang on 9/23/25.
//

import Combine
import Foundation

enum Achievement: String, Codable {
    case firstOrder = "first_order"
    case fiveOrders = "five_orders"
    case tenOrders = "ten_orders"
    case thirteenOrders = "thirteen_orders"
    case twentyRecipes = "twenty_recipes"
    case hundredRevenue = "hundred_revenue"
    case twoHundredRevenue = "two_hundred_revenue"
    
    var title: String {
        switch self {
        case .firstOrder: return "You're in business!"
        case .fiveOrders: return "Baker's Journey"
        case .tenOrders: return "Sweet Success"
        case .thirteenOrders: return "Baker's Dozen+"
        case .twentyRecipes: return "Flexing My Skills"
        case .hundredRevenue: return "Century Club"
        case .twoHundredRevenue: return "Making Bank"
        }
    }
}

final class AchievementService: ObservableObject {
    static let shared = AchievementService()
    
    private let storageKey = "achievements_unlocked"
    @Published var unlockedAchievements: Set<Achievement> = []
    
    private let achievementPublisher = PassthroughSubject<Achievement, Never>()
    var onAchievementUnlocked: AnyPublisher<Achievement, Never> {
        achievementPublisher.eraseToAnyPublisher()
    }
    
    private init() {
        loadAchievements()
    }
    
    private func loadAchievements() {
        if let data = UserDefaults.standard.data(forKey: storageKey),
           let decoded = try? JSONDecoder().decode(Set<Achievement>.self, from: data) {
            unlockedAchievements = decoded
        }
    }
    
    func checkAndUnlock(_ achievement: Achievement) {
        guard !unlockedAchievements.contains(achievement) else { return }
        
        unlockedAchievements.insert(achievement)
        save()
        achievementPublisher.send(achievement)
    }
    
    func hasUnlocked(_ achievement: Achievement) -> Bool {
        unlockedAchievements.contains(achievement)
    }
    
    private func save() {
        if let encoded = try? JSONEncoder().encode(unlockedAchievements) {
            UserDefaults.standard.set(encoded, forKey: storageKey)
        }
    }
    
    // Track metrics
    func checkRecipeCount(_ count: Int) {
        if count >= 20 {
            checkAndUnlock(.twentyRecipes)
        }
    }
    
    func checkOrderCount(_ count: Int) {
        if count >= 1 {
            checkAndUnlock(.firstOrder)
        }
        if count >= 5 {
            checkAndUnlock(.fiveOrders)
        }
        if count >= 10 {
            checkAndUnlock(.tenOrders)
        }
        if count >= 13 {
            checkAndUnlock(.thirteenOrders)
        }
    }
    
    func checkRevenue(_ revenue: Decimal) {
        if revenue >= 100 {
            checkAndUnlock(.hundredRevenue)
        }
        if revenue >= 200 {
            checkAndUnlock(.twoHundredRevenue)
        }
    }
    
    // Specific triggers for easter eggs (no random)
    func shouldShowAviArms() -> Bool {
        return hasUnlocked(.twentyRecipes) || 
               hasUnlocked(.thirteenOrders) || 
               hasUnlocked(.twoHundredRevenue)
    }
}

