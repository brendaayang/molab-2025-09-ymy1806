//
//  CancelBag.swift
//  Flavorly
//
//  Created by Brenda Yang on 10/18/25.
//

import Combine

/// A typealias for a set of `AnyCancellable` objects.
///
/// `CancelBag` is used to hold and manage a collection of cancellables, typically subscriptions
/// created when using the Combine framework. It simplifies the handling of multiple cancellables,
/// allowing for easy cancellation of all subscriptions held within the set.
typealias CancelBag = Set<AnyCancellable>

