//
//  TimerServiceProtocol.swift
//  Flavorly
//
//  Created by Brenda Yang on 10/18/25.
//

import Foundation
import Combine

protocol TimerServiceProtocol {
    var activeTimers: CurrentValueSubject<[BakingTimer], Never> { get }
    
    func addTimer(_ timer: BakingTimer)
    func removeTimer(id: UUID)
    func pauseTimer(id: UUID)
    func resumeTimer(id: UUID)
    func updateTimers()
}

