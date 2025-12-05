//
//  TabService.swift
//  Flavorly
//
//  Created by Brenda Yang on 10/18/25.
//

import Combine
import Foundation

final class TabService: TabServiceProtocol {
    private let _currentTab: CurrentValueSubject<Tab?, Never> = .init(.recipes)
    var currentTab: AnyPublisher<Tab?, Never> {
        _currentTab.eraseToAnyPublisher()
    }
    
    func setTab(to tab: Tab) {
        _currentTab.send(tab)
    }
}

