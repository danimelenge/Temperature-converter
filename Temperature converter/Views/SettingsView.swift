//
//  SettingsView.swift
//  Temperature converter
//
//  Created by Daniel Melenge Rojas on 21/07/25.
//

import SwiftUI

struct SettingsView: View {
    // MARK: - Inyección del ViewModel y Entorno
    @State private var viewModel = SettingsViewModel()
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        ZStack {
            // Fondo gestionado por el ViewModel (Mantiene el gradiente de la captura)
            let isDark = colorScheme == .dark
            
            LinearGradient(
                gradient: Gradient(colors: viewModel.backgroundGradient(isDark: isDark)),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 40) {
                Text("Configuración de Unidad")
                    .font(.title2.bold())
                    .foregroundStyle(.primary)
                    .padding(.top, 40)
                    // ACCESIBILIDAD: Indica que es un encabezado de sección
                    .accessibilityAddTraits(.isHeader)

                // MARK: - Visualización grande de unidades (HStack central)
                HStack(spacing: 60) {
                    // Bloque Celsius
                    VStack {
                        Text("°C")
                            .font(.system(size: 72, weight: .bold))
                            .foregroundColor(viewModel.colorForCelsius())
                        Text("Celsius")
                            .font(.headline)
                            .foregroundColor(.secondary)
                    }
                    // ACCESIBILIDAD: Combina "°C" y "Celsius" en una sola lectura
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel("Grados Celsius")
                    .accessibilityAddTraits(viewModel.unitSelection == 0 ? .isSelected : [])
                    .accessibilityHint(viewModel.unitSelection == 0 ? "Actualmente seleccionado" : "")

                    // Bloque Fahrenheit
                    VStack {
                        Text("°F")
                            .font(.system(size: 72, weight: .bold))
                            .foregroundColor(viewModel.colorForFahrenheit())
                        Text("Fahrenheit")
                            .font(.headline)
                            .foregroundColor(.secondary)
                    }
                    // ACCESIBILIDAD: Combina "°F" y "Fahrenheit"
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel("Grados Fahrenheit")
                    .accessibilityAddTraits(viewModel.unitSelection == 1 ? .isSelected : [])
                    .accessibilityHint(viewModel.unitSelection == 1 ? "Actualmente seleccionado" : "")
                }
                .animation(.easeInOut(duration: 0.3), value: viewModel.unitSelection)

                // MARK: - Selector de unidades (Segmented Control)
                Picker("Conversión", selection: $viewModel.unitSelection) {
                    Text("Celsius → Fahrenheit").tag(0)
                    Text("Fahrenheit → Celsius").tag(1)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, 40)
                .padding(.vertical, 12)
                .background(.ultraThinMaterial) // Mantiene el efecto de cristal de la imagen
                .cornerRadius(16)
                .shadow(color: .black.opacity(viewModel.shadowOpacity(isDark: isDark)), radius: 6)
                // ACCESIBILIDAD: Etiqueta descriptiva para el control de selección
                .accessibilityLabel("Dirección de la conversión")
                .accessibilityHint("Cambia el orden de las unidades para el conversor principal.")

                Spacer()
            }
            .frame(maxWidth: .infinity)
        }
        .navigationTitle("Settings") // Coincide con el título de la captura
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Previews
#Preview("Light Mode") {
    NavigationStack {
        SettingsView()
            .preferredColorScheme(.light)
    }
}

#Preview("Dark Mode") {
    NavigationStack {
        SettingsView()
            .preferredColorScheme(.dark)
    }
}
