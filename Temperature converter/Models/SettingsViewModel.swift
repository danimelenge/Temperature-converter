//
//  SettingsViewModel.swift
//  Temperature converter
//
//  Created by Daniel Melenge Rojas on 2/02/26.
//

import SwiftUI

@Observable
class SettingsViewModel {
    // MARK: - Estado
    // Usamos el mismo nombre de AppStorage para sincronizar con el resto de la app
    var unitSelection: Int = UserDefaults.standard.integer(forKey: "unitSelection") {
        didSet {
            UserDefaults.standard.set(unitSelection, forKey: "unitSelection")
        }
    }
    
    // MARK: - Lógica de Estilos
    func backgroundGradient(isDark: Bool) -> [Color] {
        [
            .blue.opacity(isDark ? 0.2 : 0.3),
            .orange.opacity(isDark ? 0.15 : 0.3)
        ]
    }
    
    func colorForCelsius() -> Color {
        unitSelection == 0 ? .orange : .gray.opacity(0.5)
    }
    
    func colorForFahrenheit() -> Color {
        unitSelection == 1 ? .orange : .gray.opacity(0.5)
    }
    
    func shadowOpacity(isDark: Bool) -> Double {
        isDark ? 0.4 : 0.1
    }
}
