//
//  ConversionServiceProtocol.swift
//  Flavorly
//
//  Created by Brenda Yang on 10/18/25.
//

import Foundation

protocol ConversionServiceProtocol {
    func parseQuery(_ query: String) -> ConversionResult?
}

struct ConversionResult {
    let original: String
    let converted: String
    let explanation: String
}

