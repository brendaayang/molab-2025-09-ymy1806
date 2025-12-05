//
//  Bindable.swift
//  Flavorly
//
//  Created by Brenda Yang on 10/18/25.
//

import Foundation

/// A utility class for managing Combine subscriptions. It includes a `CancelBag` for
/// efficient lifecycle management of subscriptions, ensuring they are disposed of properly to prevent memory leaks.
class Bindable {
    /// A `CancelBag` for storing and managing `AnyCancellable` objects.
    var cancelBag: CancelBag!
    
    /// Prepares the `Bindable` instance for managing subscriptions by initializing `cancelBag`.
    /// This method should be called before adding any subscriptions to the `cancelBag`.
    func bind() {
        self.cancelBag = CancelBag()
    }
}

