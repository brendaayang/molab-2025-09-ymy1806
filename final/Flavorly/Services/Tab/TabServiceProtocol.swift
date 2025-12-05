//
//  TabServiceProtocol.swift
//  Flavorly
//
//  Created by Brenda Yang on 10/18/25.
//

import Combine

protocol TabServiceProtocol {
    var currentTab: AnyPublisher<Tab?, Never> { get }
    func setTab(to tab: Tab)
}

