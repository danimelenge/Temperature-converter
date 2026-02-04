//
//  ConvertTemperatureIntent.swift
//  Temperature converter
//
//  Created by Daniel Melenge Rojas on 4/02/26.
//

import AppIntents
import SwiftUI

struct ConvertTemperatureIntent: AppIntent {
    // El título que aparece en la app de Atajos
    static var title: LocalizedStringResource = "Convertir Temperatura"
    
    // El parámetro que Siri buscará (los grados)
    @Parameter(title: "Grados", description: "La cantidad numérica a convertir")
    var value: Double

    // El parámetro para la unidad de origen
    @Parameter(title: "Unidad", description: "Celsius o Fahrenheit", default: "Celsius")
    var unit: String

    // Define cómo Siri debe escuchar el comando
    static var parameterSummary: some ParameterSummary {
        Summary("Convierte \(\.$value) grados \(\.$unit)")
    }

    // La lógica de la conversión
    func perform() async throws -> some IntentResult & ReturnsValue<String> & ProvidesDialog {
        let inputUnit = unit.lowercased().contains("f") ? UnitTemperature.fahrenheit : UnitTemperature.celsius
        let outputUnit = inputUnit == .celsius ? UnitTemperature.fahrenheit : UnitTemperature.celsius
        
        let measurement = Measurement(value: value, unit: inputUnit)
        let converted = measurement.converted(to: outputUnit)
        
        let formatter = MeasurementFormatter()
        formatter.unitOptions = .providedUnit
        formatter.numberFormatter.maximumFractionDigits = 1
        
        let resultString = formatter.string(from: converted)
        
        // Lo que Siri dirá de vuelta
        return .result(value: resultString, dialog: "El resultado es \(resultString)")
    }
}
