//
//  ShakeDetector.swift
//  Flavorly
//
//  Created by Brenda Yang on 10/18/25.
//

import UIKit
import SwiftUI

class ShakeDetector: ObservableObject {
    @Published var didShake = false
    
    init() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(deviceDidShake),
            name: UIDevice.deviceDidShakeNotification,
            object: nil
        )
    }
    
    @objc func deviceDidShake() {
        didShake = true
        
        // Reset after a moment
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.didShake = false
        }
    }
}

extension UIDevice {
    static let deviceDidShakeNotification = Notification.Name(rawValue: "deviceDidShakeNotification")
}

extension UIWindow {
    open override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            NotificationCenter.default.post(name: UIDevice.deviceDidShakeNotification, object: nil)
        }
    }
}

