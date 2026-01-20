//
//  ConversionHistory.swift
//  Temperature converter
//
//  Created by Daniel Melenge Rojas on 20/01/26.
//

import Foundation
import SwiftData

@Model
final class ConversionHistory {
    var inputAmount: Double
    var inputUnit: String
    var resultAmount: Double
    var resultUnit: String
    var timestamp: Date
    
    init(inputAmount: Double, inputUnit: String, resultAmount: Double, resultUnit: String) {
        self.inputAmount = inputAmount
        self.inputUnit = inputUnit
        self.resultAmount = resultAmount
        self.resultUnit = resultUnit
        self.timestamp = Date()
    }
}
