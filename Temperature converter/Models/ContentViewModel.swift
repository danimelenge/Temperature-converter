//
//  ContentViewModel.swift
//  Temperature converter
//
//  Created by Daniel Melenge Rojas on 30/01/26.
//

import SwiftUI
import SwiftData

@Observable
class ContentViewModel {
    // MARK: - Estado de la Interfaz
    var inputValue: Double = 0
    var unitSelection: Int = 0
    var selectedTab: Int = 0
    var saveTrigger: Bool = false
    
    // MARK: - Lógica de Conversión
    var convertedValue: Double {
        unitSelection == 0 ? inputValue * 9 / 5 + 32 : (inputValue - 32) * 5 / 9
    }
    
    var temperatureDescription: String {
        let celsius = unitSelection == 0 ? inputValue : convertedValue
        switch celsius {
        case ..<0: return "❄️ Muy frío"
        case 0..<10: return "🧊 Frío"
        case 10..<25: return "🌤️ Templado"
        case 25..<35: return "🔥 Caliente"
        default: return "☀️ Muy caliente"
        }
    }
    
    // MARK: - Estética Dinámica
    func backgroundGradient(isDark: Bool) -> [Color] {
        let celsius = unitSelection == 0 ? inputValue : convertedValue
        let opacity1 = isDark ? 0.4 : 0.6
        let opacity2 = isDark ? 0.2 : 0.3

        switch celsius {
        case ..<0: return [.blue.opacity(opacity1), .cyan.opacity(opacity2)]
        case 0..<10: return [.blue.opacity(opacity1), .teal.opacity(opacity2)]
        case 10..<25: return [.green.opacity(opacity1), .yellow.opacity(opacity2)]
        case 25..<35: return [.orange.opacity(opacity1), .red.opacity(opacity2)]
        default: return [.red.opacity(opacity1), .orange.opacity(opacity2)]
        }
    }

    var iconName: String {
        let celsius = unitSelection == 0 ? inputValue : convertedValue
        switch celsius {
        case ..<0: return "snowflake"
        case 0..<25: return "thermometer"
        default: return "flame.fill"
        }
    }

    var iconColor: Color {
        let celsius = unitSelection == 0 ? inputValue : convertedValue
        switch celsius {
        case ..<0: return .cyan
        case 0..<25: return .orange
        default: return .red
        }
    }

    var iconAnimationScale: CGFloat {
        iconName == "flame.fill" ? 1.1 : (iconName == "snowflake" ? 0.9 : 1.0)
    }

    // MARK: - Acciones (SwiftData se maneja desde la View habitualmente,
    // pero la lógica de preparación va aquí)
    func saveConversion(modelContext: ModelContext, history: [ConversionHistory]) {
        let newRecord = ConversionHistory(
            inputAmount: inputValue,
            inputUnit: unitSelection == 0 ? "C" : "F",
            resultAmount: convertedValue,
            resultUnit: unitSelection == 0 ? "F" : "C"
        )
        
        modelContext.insert(newRecord)
        saveTrigger.toggle()
        
        // Lógica de limpieza
        if history.count > 10 {
            history.suffix(from: 10).forEach { modelContext.delete($0) }
        }
    }
}
