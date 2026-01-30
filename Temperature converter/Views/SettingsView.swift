//
//  SettingsView.swift
//  Temperature converter
//
//  Created by Daniel Melenge Rojas on 21/07/25.
//

import SwiftUI

struct SettingsView: View {
    // MARK: - Entorno para detectar Modo Oscuro
    @Environment(\.colorScheme) var colorScheme
    
    // MARK: - Estado persistente de unidad seleccionada
    @AppStorage("unitSelection") private var unitSelection: Int = 0

    var body: some View {
        ZStack {
            // MARK: - Fondo degradado dinámico adaptado
            let isDark = colorScheme == .dark
            
            LinearGradient(
                gradient: Gradient(colors: [
                    .blue.opacity(isDark ? 0.2 : 0.3),
                    .orange.opacity(isDark ? 0.15 : 0.3)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            // MARK: - Contenido principal
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
                            .foregroundColor(unitSelection == 0 ? .orange : .gray.opacity(0.5))
                        Text("Celsius")
                            .font(.headline)
                            .foregroundColor(.secondary)
                    }

                    VStack {
                        Text("°F")
                            .font(.system(size: 72, weight: .bold))
                            .foregroundColor(unitSelection == 1 ? .orange : .gray.opacity(0.5))
                        Text("Fahrenheit")
                            .font(.headline)
                            .foregroundColor(.secondary)
                    }
                }
                .animation(.easeInOut(duration: 0.3), value: unitSelection)

                // MARK: - Selector de unidades
                Picker("Conversión", selection: $unitSelection) {
                    Text("Celsius → Fahrenheit").tag(0)
                    Text("Fahrenheit → Celsius").tag(1)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, 40)
                .padding(.vertical, 12)
                .background(.ultraThinMaterial) // Se adapta automáticamente a Dark Mode
                .cornerRadius(16)
                .shadow(color: .black.opacity(isDark ? 0.4 : 0.1), radius: 6)

                Spacer()
            }
            .frame(maxWidth: .infinity)
        }
        .navigationTitle("Ajustes")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Vistas Previas Dinámicas
#Preview("Light Mode") {
    NavigationStack { // Añadido para ver el título correctamente
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
