//
//  ContentView.swift
//  Temperature converter
//
//  Created by Daniel Melenge Rojas on 21/07/25.
//


import SwiftUI

struct ContentView: View {

    // MARK: - Propiedades de estado

    /// Guarda la selección del usuario para la unidad de temperatura (0 = Celsius → Fahrenheit, 1 = Fahrenheit → Celsius)
    @AppStorage("unitSelection") private var unitSelection: Int = 0

    /// Valor ingresado por el usuario en grados
    @State private var inputValue: Double = 0

    // MARK: - Cálculo de conversión

    /// Valor convertido según la unidad seleccionada
    private var convertedValue: Double {
        unitSelection == 0
        ? inputValue * 9 / 5 + 32
        : (inputValue - 32) * 5 / 9
    }

    // MARK: - Descripción del estado térmico

    /// Retorna un texto que describe el estado visual basado en el valor en grados Celsius
    private var temperatureDescription: String {
        let celsius = unitSelection == 0 ? inputValue : convertedValue
        switch celsius {
        case ..<0: return "Muy frío"
        case 0..<10: return "Frío"
        case 10..<25: return "Templado"
        case 25..<35: return "Caliente"
        default: return "Muy caliente"
        }
    }

    // MARK: - Colores dinámicos de fondo

    /// Color de fondo adaptado al rango de temperatura
    private var backgroundColor: Color {
        let celsius = unitSelection == 0 ? inputValue : convertedValue
        switch celsius {
        case ..<0: return .blue.opacity(0.2)
        case 0..<10: return .blue.opacity(0.1)
        case 10..<25: return .gray.opacity(0.1)
        case 25..<35: return .orange.opacity(0.1)
        default: return .red.opacity(0.2)
        }
    }

    // MARK: - Icono visual por temperatura

    /// Icono de SF Symbols que representa la temperatura
    private var iconName: String {
        let celsius = unitSelection == 0 ? inputValue : convertedValue
        switch celsius {
        case ..<0: return "snow"
        case 0..<25: return "thermometer"
        default: return "flame"
        }
    }

    /// Color del icono; rojo si está muy caliente
    private var iconColor: Color {
        let celsius = unitSelection == 0 ? inputValue : convertedValue
        return celsius >= 35 ? .red : .accentColor
    }

    // MARK: - Vista principal

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Spacer()

                // Icono con color dinámico y animación
                Image(systemName: iconName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 60, height: 60)
                    .foregroundColor(iconColor)
                    .animation(.easeInOut(duration: 0.3), value: iconColor)

                // Texto de conversión entre unidades
                Text("\(inputValue, specifier: "%.1f")° \(unitSelection == 0 ? "C" : "F") es \(convertedValue, specifier: "%.1f")° \(unitSelection == 0 ? "F" : "C")")
                    .font(.title3)
                    .bold()

                // Descripción visual del estado térmico
                Text(temperatureDescription)
                    .font(.headline)
                    .padding(.horizontal)
                    .padding(.vertical, 6)
                    .background(Capsule().fill(Color.primary.opacity(0.1)))
                    .animation(.easeInOut, value: temperatureDescription)

                // Control deslizante para modificar la temperatura
                Slider(value: $inputValue, in: -50...50)
                    .padding()

                // Botón para navegar a vista de estado visual
                NavigationLink("Ver Estado Visual") {
                    EstadoView(celsius: unitSelection == 0 ? inputValue : convertedValue)
                }
                .buttonStyle(.borderedProminent)

                // Botón para navegar a ajustes
                NavigationLink("Ajustes") {
                    SettingsView()
                }

                Spacer()
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(backgroundColor)
                    .animation(.easeInOut, value: backgroundColor)
            )
            .padding()
            .navigationTitle("Conversor de Temperatura")
        }
    }
}

// MARK: - Vista previa

#Preview {
    ContentView()
}
