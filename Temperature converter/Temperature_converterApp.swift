//
//  Temperature_converterApp.swift
//  Temperature converter
//
//  Created by Daniel Melenge Rojas on 21/07/25.
//

import SwiftUI
import SwiftData

@main
struct TemperatureConverterApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        // Añadimos el modelo al contenedor
        .modelContainer(for: ConversionHistory.self)
    }
}
    
        
