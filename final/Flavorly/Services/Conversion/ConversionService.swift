//
//  ConversionService.swift
//  Flavorly
//
//  Created by Brenda Yang on 10/18/25.
//

import Foundation

final class ConversionService: ConversionServiceProtocol {
    
    func parseQuery(_ query: String) -> ConversionResult? {
        let lowercased = query.lowercased()
            .replacingOccurrences(of: "what is", with: "")
            .replacingOccurrences(of: "how much is", with: "")
            .replacingOccurrences(of: "convert", with: "")
            .trimmingCharacters(in: .whitespaces)
        
        // Extract numbers
        let numberPattern = "([0-9]+\\.?[0-9]*)"
        guard let regex = try? NSRegularExpression(pattern: numberPattern),
              let match = regex.firstMatch(in: lowercased, range: NSRange(lowercased.startIndex..., in: lowercased)),
              let numberRange = Range(match.range, in: lowercased) else {
            return nil
        }
        
        guard let value = Double(lowercased[numberRange]) else { return nil }
        
        // Grams to/from Cups (detect direction)
        if lowercased.contains("gram") && lowercased.contains("cup") {
            let gramIndex = lowercased.range(of: "gram")!.lowerBound
            let cupIndex = lowercased.range(of: "cup")!.lowerBound
            
            if gramIndex < cupIndex {
                // Grams TO cups
                let cups = value / 125.0
                return ConversionResult(
                    original: "\(Int(value))g",
                    converted: String(format: "%.2f cups", cups),
                    explanation: "using flour density (1 cup ≈ 125g)"
                )
            } else {
                // Cups TO grams
                let grams = value * 125.0
                return ConversionResult(
                    original: "\(value) cup\(value != 1 ? "s" : "")",
                    converted: "\(Int(grams))g",
                    explanation: "using flour density (1 cup ≈ 125g)"
                )
            }
        }
        
        // Tablespoon/teaspoon conversions
        if lowercased.contains("tablespoon") && lowercased.contains("teaspoon") {
            let tbspIndex = lowercased.range(of: "tablespoon")!.lowerBound
            let tspIndex = lowercased.range(of: "teaspoon")!.lowerBound
            
            if tbspIndex < tspIndex {
                let teaspoons = value * 3
                return ConversionResult(
                    original: "\(Int(value)) tbsp",
                    converted: "\(Int(teaspoons)) tsp",
                    explanation: "1 tablespoon = 3 teaspoons"
                )
            } else {
                let tablespoons = value / 3.0
                return ConversionResult(
                    original: "\(Int(value)) tsp",
                    converted: String(format: "%.2f tbsp", tablespoons),
                    explanation: "3 teaspoons = 1 tablespoon"
                )
            }
        }
        
        // Temperature conversions
        if lowercased.contains("celsius") && lowercased.contains("fahrenheit") {
            let celsiusIndex = lowercased.range(of: "celsius")!.lowerBound
            let fahrenheitIndex = lowercased.range(of: "fahrenheit")!.lowerBound
            
            if celsiusIndex < fahrenheitIndex {
                let fahrenheit = (value * 9/5) + 32
                return ConversionResult(
                    original: "\(Int(value))°c",
                    converted: "\(Int(fahrenheit))°f",
                    explanation: "f = (c × 9/5) + 32"
                )
            } else {
                let celsius = (value - 32) * 5/9
                return ConversionResult(
                    original: "\(Int(value))°f",
                    converted: "\(Int(celsius))°c",
                    explanation: "c = (f - 32) × 5/9"
                )
            }
        }
        
        // Ounce/gram conversions
        if lowercased.contains("ounce") && lowercased.contains("gram") {
            let ounceIndex = lowercased.range(of: "ounce")!.lowerBound
            let gramIndex = lowercased.range(of: "gram")!.lowerBound
            
            if ounceIndex < gramIndex {
                let grams = value * 28.35
                return ConversionResult(
                    original: "\(value) oz",
                    converted: String(format: "%.1fg", grams),
                    explanation: "1 ounce = 28.35 grams"
                )
            } else {
                let ounces = value / 28.35
                return ConversionResult(
                    original: "\(Int(value))g",
                    converted: String(format: "%.2f oz", ounces),
                    explanation: "1 ounce = 28.35 grams"
                )
            }
        }
        
        return nil
    }
}

