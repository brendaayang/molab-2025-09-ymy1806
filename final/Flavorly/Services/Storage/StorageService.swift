//
//  StorageService.swift
//  Flavorly
//
//  Created by Brenda Yang on 10/18/25.
//

import Foundation

final class StorageService: StorageServiceProtocol {
    private let userDefaults = UserDefaults.standard
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    
    func setValue<T: Codable>(_ value: T, forKey key: String) {
        if let data = try? encoder.encode(value) {
            userDefaults.set(data, forKey: key)
        }
    }
    
    func getValue<T: Codable>(forKey key: String) -> T? {
        guard let data = userDefaults.data(forKey: key) else {
            return nil
        }
        return try? decoder.decode(T.self, from: data)
    }
    
    func removeValue(forKey key: String) {
        userDefaults.removeObject(forKey: key)
    }
    
    func clearAll() {
        if let bundleIdentifier = Bundle.main.bundleIdentifier {
            userDefaults.removePersistentDomain(forName: bundleIdentifier)
        }
    }
}

