//
//  StorageServiceProtocol.swift
//  Flavorly
//
//  Created by Brenda Yang on 10/18/25.
//

import Foundation

protocol StorageServiceProtocol {
    func setValue<T: Codable>(_ value: T, forKey key: String)
    func getValue<T: Codable>(forKey key: String) -> T?
    func removeValue(forKey key: String)
    func clearAll()
}

