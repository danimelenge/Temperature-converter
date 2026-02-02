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
            // Fondo gestionado por el ViewModel
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

                // MARK: - Visualización grande de unidades
                HStack(spacing: 60) {
                    VStack {
                        Text("°C")
                            .font(.system(size: 72, weight: .bold))
                            .foregroundColor(viewModel.colorForCelsius())
                        Text("Celsius")
                            .font(.headline)
                            .foregroundColor(.secondary)
                    }

                    VStack {
                        Text("°F")
                            .font(.system(size: 72, weight: .bold))
                            .foregroundColor(viewModel.colorForFahrenheit())
                        Text("Fahrenheit")
                            .font(.headline)
                            .foregroundColor(.secondary)
                    }
                }
                .animation(.easeInOut(duration: 0.3), value: viewModel.unitSelection)

                // MARK: - Selector de unidades
                Picker("Conversión", selection: $viewModel.unitSelection) {
                    Text("Celsius → Fahrenheit").tag(0)
                    Text("Fahrenheit → Celsius").tag(1)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, 40)
                .padding(.vertical, 12)
                .background(.ultraThinMaterial)
                .cornerRadius(16)
                .shadow(color: .black.opacity(viewModel.shadowOpacity(isDark: isDark)), radius: 6)

                Spacer()
            }
            .frame(maxWidth: .infinity)
        }
        .navigationTitle("Ajustes")
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
