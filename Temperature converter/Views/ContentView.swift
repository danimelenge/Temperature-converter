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

    // MARK: - Estados y Configuración Existentes
    @State private var selectedTab = 0
    @AppStorage("unitSelection") private var unitSelection: Int = 0
    @State private var inputValue: Double = 0

    // MARK: - Estados para WhatsNew (Onboarding)
    @AppStorage("hasSeenOnboarding") var hasSeenOnboarding: Bool = false
    @State private var showWhatsNew: Bool = false
    
    // MARK: - Estados para Feedback Sensorial
    @State private var saveTrigger = false // Dispara vibración al guardar

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
        // --- FEEDBACK SENSORIAL ---
        // Vibra cuando guardamos (Impacto medio)
        .sensoryFeedback(.impact(weight: .medium), trigger: saveTrigger)
        // Vibra suavemente mientras movemos el slider (Efecto selección)
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
            // Fondo dinámico
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

                    // --- BOTÓN REDISEÑADO CON VIBRACIÓN ---
                    Button(action: {
                        saveConversion(
                            input: inputValue,
                            from: unitSelection == 0 ? "C" : "F",
                            result: convertedValue,
                            to: unitSelection == 0 ? "F" : "C"
                        )
                        saveTrigger.toggle() // Activa la vibración
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

                // MARK: - Control deslizante (Con vibración selección activada en el trigger de arriba)
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

    // MARK: - Lógica de SwiftData para Guardar
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

    // MARK: - Cálculos y propiedades dinámicas
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

    private var backgroundGradient: [Color] {
        let celsius = unitSelection == 0 ? inputValue : convertedValue
        switch celsius {
        case ..<0: return [.blue.opacity(0.6), .cyan.opacity(0.3)]
        case 0..<10: return [.blue.opacity(0.4), .teal.opacity(0.3)]
        case 10..<25: return [.green.opacity(0.3), .yellow.opacity(0.2)]
        case 25..<35: return [.orange.opacity(0.4), .red.opacity(0.3)]
        default: return [.red.opacity(0.6), .orange.opacity(0.4)]
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

// MARK: - Vista previa
#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: ConversionHistory.self, configurations: config)
    return ContentView().modelContainer(container)
}
