//
//  AppEnvironmentConfig.swift
//  Flavorly
//
//  Created by Brenda Yang on 09/23/25.
//

import Foundation

enum AppEnvironment {
    case dev
    case release

    static var current: AppEnvironment {
        #if DEBUG
            return .dev
        #else
            return .release
        #endif
    }
}

struct AppConfig {
    static let appName: String = "Flavorly"
    static let version: String = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
}

