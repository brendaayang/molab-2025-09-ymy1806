//
//  AppLoginService.swift
//  Flavorly
//
//  Created by Brenda Yang on 10/18/25.
//

import Foundation

final class AppLoginService {
    static let shared = AppLoginService()
    private let lastLoginKey = "lastAppLogin"
    
    private init() {}
    
    var lastLoginDate: Date? {
        UserDefaults.standard.object(forKey: lastLoginKey) as? Date
    }
    
    func recordLogin() {
        UserDefaults.standard.set(Date(), forKey: lastLoginKey)
        print("✅ App login recorded: \(Date())")
    }
    
    func daysSinceLastLogin() -> Int? {
        guard let lastLogin = lastLoginDate else { return nil }
        return Calendar.current.dateComponents([.day], from: lastLogin, to: Date()).day
    }
}

