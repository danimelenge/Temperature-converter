//
//  AppShortcutsProvider.swift
//  Temperature converter
//
//  Created by Daniel Melenge Rojas on 4/02/26.
//

import AppIntents

struct TemperatureShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: ConvertTemperatureIntent(),
            phrases: [
                "Convierte \(\.$value) grados \(\.$unit) en \(.applicationName)",
                "Calcula \(\.$value) grados \(\.$unit) con \(.applicationName)",
                "En \(.applicationName) convierte \(\.$value) grados"
            ],
            shortTitle: "Conversión de Voz",
            systemImageName: "thermometer.medium"
        )
    }
}
