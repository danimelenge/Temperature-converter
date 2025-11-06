//
//  ContentView.swift
//  Temperature converter
//
//  Created by Daniel Melenge Rojas on 21/07/25.
//


import SwiftUI

// MARK: - Vista Principal de la App
struct ContentView: View {
    // MARK: - Estados y Configuración
    @State private var selectedTab = 0              // Controla la pestaña seleccionada del TabView
    @AppStorage("unitSelection") private var unitSelection: Int = 0  // Guarda la unidad seleccionada (C/F) de forma persistente
    @State private var inputValue: Double = 0       // Valor numérico de entrada para convertir

    // MARK: - Cuerpo de la vista
    var body: some View {
        ZStack {
            // Fondo degradado principal
            LinearGradient(
                gradient: Gradient(colors: [.blue.opacity(0.2), .orange.opacity(0.2)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            // MARK: - Contenedor principal con pestañas
            TabView(selection: $selectedTab) {
                // --- PRIMERA PESTAÑA: CONVERSOR ---
                conversionView
                    .tabItem {
                        Label("Convertir", systemImage: "thermometer.sun")
                    }
                    .tag(0)

                // --- SEGUNDA PESTAÑA: AJUSTES ---
                SettingsView()
                    .tabItem {
                        Label("Ajustes", systemImage: "gearshape")
                    }
                    .tag(1)
            }
            .tint(.orange)
            .animation(.easeInOut(duration: 0.3), value: selectedTab)
            .onChange(of: selectedTab) {
                print("Cambio de tab a \(selectedTab)")
                // FIXME: Reemplazar print con lógica o analytics si se requiere registro real
            }
        }
    }

    // MARK: - SUBVISTA: Conversión de temperatura
    private var conversionView: some View {
        ZStack {
            // Fondo dinámico que cambia según la temperatura
            LinearGradient(
                gradient: Gradient(colors: backgroundGradient),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            .animation(.easeInOut(duration: 0.5), value: backgroundGradient)

            VStack(spacing: 28) {
                // MARK: - Ícono de estado térmico
                Image(systemName: iconName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 90, height: 90)
                    .foregroundStyle(iconColor)
                    .shadow(color: iconColor.opacity(0.5), radius: 10)
                    .scaleEffect(iconAnimationScale)
                    .animation(.spring(response: 0.6, dampingFraction: 0.5), value: iconName)
                    // TODO: Podría agregarse una animación de rotación o pulsación leve para hacerlo más visual

                // MARK: - Resultado de conversión
                Text("\(inputValue, specifier: "%.1f")° \(unitSelection == 0 ? "C" : "F") = \(convertedValue, specifier: "%.1f")° \(unitSelection == 0 ? "F" : "C")")
                    .font(.title3)
                    .bold()
                    // NOTE: Este texto muestra la conversión dinámica de temperatura

                // MARK: - Descripción del estado térmico
                Text(temperatureDescription)
                    .font(.headline)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(.ultraThinMaterial)
                    .cornerRadius(16)
                    .shadow(radius: 4)

                // MARK: - Control deslizante
                VStack {
                    Slider(value: $inputValue, in: -50...50)
                        .tint(iconColor)
                    Text("Ajusta la temperatura")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal)
                // FIXME: Podrías agregar una etiqueta de valor actual sobre el slider

                Spacer(minLength: 40)
            }
            .padding()
        }
    }

    // MARK: - Cálculos y propiedades dinámicas

    /// Convierte el valor de entrada según la unidad seleccionada
    private var convertedValue: Double {
        unitSelection == 0
        ? inputValue * 9 / 5 + 32   // Celsius → Fahrenheit
        : (inputValue - 32) * 5 / 9 // Fahrenheit → Celsius
    }

    /// Devuelve una descripción textual según el rango de temperatura
    private var temperatureDescription: String {
        let celsius = unitSelection == 0 ? inputValue : convertedValue
        switch celsius {
        case ..<0: return "❄️ Muy frío"
        case 0..<10: return "🧊 Frío"
        case 10..<25: return "🌤️ Templado"
        case 25..<35: return "🔥 Caliente"
        default: return "☀️ Muy caliente"
        }
        // TODO: Personalizar mensajes según idioma o preferencias del usuario
    }

    /// Devuelve un arreglo de colores para el fondo según temperatura
    private var backgroundGradient: [Color] {
        let celsius = unitSelection == 0 ? inputValue : convertedValue
        switch celsius {
        case ..<0: return [.blue.opacity(0.6), .cyan.opacity(0.3)]
        case 0..<10: return [.blue.opacity(0.4), .teal.opacity(0.3)]
        case 10..<25: return [.green.opacity(0.3), .yellow.opacity(0.2)]
        case 25..<35: return [.orange.opacity(0.4), .red.opacity(0.3)]
        default: return [.red.opacity(0.6), .orange.opacity(0.4)]
        }
        // NOTE: Podría optimizarse usando un gradiente interpolado dinámico en lugar de rangos discretos
    }

    /// Devuelve el ícono adecuado según la temperatura
    private var iconName: String {
        let celsius = unitSelection == 0 ? inputValue : convertedValue
        switch celsius {
        case ..<0: return "snowflake"
        case 0..<25: return "thermometer"
        default: return "flame.fill"
        }
    }

    /// Devuelve el color del ícono según temperatura
    private var iconColor: Color {
        let celsius = unitSelection == 0 ? inputValue : convertedValue
        switch celsius {
        case ..<0: return .cyan
        case 0..<25: return .orange
        default: return .red
        }
        // FIXME: Ajustar colores para modo oscuro/claro si es necesario
    }

    /// Ajusta la escala de animación del ícono
    private var iconAnimationScale: CGFloat {
        switch iconName {
        case "flame.fill": return 1.1
        case "snowflake": return 0.9
        default: return 1.0
        }
        // NOTE: El efecto de escala agrega un toque visual según el estado térmico
    }
}

// MARK: - Vista previa en Canvas (solo desarrollo)
#Preview {
    ContentView()
}
