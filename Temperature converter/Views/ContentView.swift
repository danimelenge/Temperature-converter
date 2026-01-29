//
//  ContentView.swift
//  Temperature converter
//
//  Created by Daniel Melenge Rojas on 21/07/25.
//

import SwiftUI
import SwiftData

// MARK: - Vista Principal de la App
struct ContentView: View {
    // MARK: - SwiftData Propiedades
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \ConversionHistory.timestamp, order: .reverse) var history: [ConversionHistory]

    // MARK: - Entorno
    @Environment(\.colorScheme) var colorScheme

    // MARK: - Estados y Configuración
    @State private var selectedTab = 0
    @AppStorage("unitSelection") private var unitSelection: Int = 0
    @State private var inputValue: Double = 0

    // MARK: - Estados para Onboarding
    @AppStorage("hasSeenOnboarding") var hasSeenOnboarding: Bool = false
    @State private var showWhatsNew: Bool = false
    
    // MARK: - Estados para Feedback Sensorial
    @State private var saveTrigger = false

    // MARK: - Cuerpo de la vista
    var body: some View {
        ZStack {
            // Fondo base que respeta el sistema
            Color(uiColor: .systemBackground)
                .ignoresSafeArea()

            // MARK: - Contenedor principal con pestañas
            TabView(selection: $selectedTab) {
                // --- PESTAÑA 0: CONVERSOR ---
                conversionView
                    .tabItem {
                        Label("Convertir", systemImage: "thermometer.sun")
                    }
                    .tag(0)

                // --- PESTAÑA 1: HISTORIAL ---
                HistoryListView()
                    .tabItem {
                        Label("Historial", systemImage: "clock.arrow.circlepath")
                    }
                    .tag(1)

                // --- PESTAÑA 2: AJUSTES ---
                SettingsView()
                    .tabItem {
                        Label("Ajustes", systemImage: "gearshape")
                    }
                    .tag(2)
            }
            .tint(.orange)
            .animation(.easeInOut(duration: 0.3), value: selectedTab)
        }
        .sensoryFeedback(.impact(weight: .medium), trigger: saveTrigger)
        .sensoryFeedback(.selection, trigger: inputValue)
        
        .onAppear {
            if !hasSeenOnboarding {
                showWhatsNew = true
            }
        }
        .sheet(isPresented: $showWhatsNew, onDismiss: {
            hasSeenOnboarding = true
        }) {
            WhatsNewView()
                .interactiveDismissDisabled()
        }
    }

    // MARK: - SUBVISTA: Conversión de temperatura
    private var conversionView: some View {
        ZStack {
            // MARK: - Propiedades Dinámicas Adaptadas (Fondo)
            LinearGradient(
                gradient: Gradient(colors: backgroundGradient),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            .animation(.easeInOut(duration: 0.5), value: backgroundGradient)

            VStack(spacing: 28) {
                Spacer()

                // MARK: - Ícono de estado térmico
                Image(systemName: iconName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .foregroundStyle(iconColor)
                    .shadow(color: iconColor.opacity(0.5), radius: 10)
                    .scaleEffect(iconAnimationScale)
                    .animation(.spring(response: 0.6, dampingFraction: 0.5), value: iconName)

                // MARK: - Resultado y Botón de Guardado
                VStack(spacing: 15) {
                    Text("\(inputValue, specifier: "%.1f")° \(unitSelection == 0 ? "C" : "F") = \(convertedValue, specifier: "%.1f")° \(unitSelection == 0 ? "F" : "C")")
                        .font(.title2)
                        .bold()
                        .multilineTextAlignment(.center)
                        .contentTransition(.numericText())
                        .animation(.snappy, value: inputValue)

                    Button(action: {
                        saveConversion(
                            input: inputValue,
                            from: unitSelection == 0 ? "C" : "F",
                            result: convertedValue,
                            to: unitSelection == 0 ? "F" : "C"
                        )
                        saveTrigger.toggle()
                    }) {
                        Label("Guardar historial", systemImage: "plus.app.fill")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundStyle(.white)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 16)
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.orange, Color.orange.opacity(0.8), Color.red.opacity(0.5)]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .clipShape(Capsule())
                            .shadow(color: .orange.opacity(0.4), radius: 6, x: 0, y: 3)
                    }
                    .buttonStyle(.plain)
                }

                // MARK: - Descripción del estado térmico
                Text(temperatureDescription)
                    .font(.headline)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(.ultraThinMaterial)
                    .cornerRadius(16)
                    .shadow(radius: 4)

                // MARK: - Control deslizante
                VStack(spacing: 8) {
                    Slider(value: $inputValue, in: -50...50)
                        .tint(iconColor)
                    Text("Ajusta la temperatura")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, 32)

                Spacer()
            }
            .frame(maxWidth: .infinity)
            .padding()
        }
    }

    // MARK: - Lógica de SwiftData
    func saveConversion(input: Double, from: String, result: Double, to: String) {
        let newRecord = ConversionHistory(
            inputAmount: input,
            inputUnit: from,
            resultAmount: result,
            resultUnit: to
        )
        modelContext.insert(newRecord)
        try? modelContext.save()
        
        if history.count > 10 {
            let excess = history.suffix(from: 10)
            for record in excess {
                modelContext.delete(record)
            }
        }
    }

    // MARK: - Propiedades Dinámicas Adaptadas
    private var backgroundGradient: [Color] {
        let celsius = unitSelection == 0 ? inputValue : convertedValue
        let isDark = colorScheme == .dark
        let opacity1 = isDark ? 0.4 : 0.6
        let opacity2 = isDark ? 0.2 : 0.3

        switch celsius {
        case ..<0:
            return [.blue.opacity(opacity1), .cyan.opacity(opacity2)]
        case 0..<10:
            return [.blue.opacity(opacity1), .teal.opacity(opacity2)]
        case 10..<25:
            return [.green.opacity(opacity1), .yellow.opacity(opacity2)]
        case 25..<35:
            return [.orange.opacity(opacity1), .red.opacity(opacity2)]
        default:
            return [.red.opacity(opacity1), .orange.opacity(opacity2)]
        }
    }

    private var convertedValue: Double {
        unitSelection == 0 ? inputValue * 9 / 5 + 32 : (inputValue - 32) * 5 / 9
    }

    private var temperatureDescription: String {
        let celsius = unitSelection == 0 ? inputValue : convertedValue
        switch celsius {
        case ..<0: return "❄️ Muy frío"
        case 0..<10: return "🧊 Frío"
        case 10..<25: return "🌤️ Templado"
        case 25..<35: return "🔥 Caliente"
        default: return "☀️ Muy caliente"
        }
    }

    private var iconName: String {
        let celsius = unitSelection == 0 ? inputValue : convertedValue
        switch celsius {
        case ..<0: return "snowflake"
        case 0..<25: return "thermometer"
        default: return "flame.fill"
        }
    }

    private var iconColor: Color {
        let celsius = unitSelection == 0 ? inputValue : convertedValue
        switch celsius {
        case ..<0: return .cyan
        case 0..<25: return .orange
        default: return .red
        }
    }

    private var iconAnimationScale: CGFloat {
        switch iconName {
        case "flame.fill": return 1.1
        case "snowflake": return 0.9
        default: return 1.0
        }
    }
}

// MARK: - Vistas Previas (Previews)
#Preview("Light Mode") {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: ConversionHistory.self, configurations: config)
    
    return ContentView()
        .preferredColorScheme(.light)
        .modelContainer(container)
}

#Preview("Dark Mode") {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: ConversionHistory.self, configurations: config)
    
    return ContentView()
        .preferredColorScheme(.dark)
        .modelContainer(container)
}
