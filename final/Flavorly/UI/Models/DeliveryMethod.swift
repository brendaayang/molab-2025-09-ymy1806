//
//  DeliveryMethod.swift
//  Flavorly
//
//  Created by Brenda Yang on 10/18/25.
//

import Foundation

enum DeliveryMethod: String, Codable, CaseIterable {
    case pickup = "Pickup"
    case delivery = "Delivery"
    
    var icon: String {
        switch self {
        case .pickup:
            return "bag.fill"
        case .delivery:
            return "car.fill"
        }
    }
}

