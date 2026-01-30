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
    // MARK: - Inyección del ViewModel y Entorno
    @State private var viewModel = ContentViewModel()
    @Environment(\.modelContext) private var modelContext
    @Environment(\.colorScheme) var colorScheme
    @Query(sort: \ConversionHistory.timestamp, order: .reverse) var history: [ConversionHistory]

    // MARK: - Estados de Persistencia Simple
    @AppStorage("hasSeenOnboarding") var hasSeenOnboarding: Bool = false
    @State private var showWhatsNew: Bool = false

    // MARK: - Cuerpo de la vista
    var body: some View {
        ZStack {
            // Fondo base que respeta el sistema
            Color(uiColor: .systemBackground)
                .ignoresSafeArea()

            // MARK: - Contenedor principal con pestañas
            TabView(selection: $viewModel.selectedTab) {
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
            .animation(.easeInOut(duration: 0.3), value: viewModel.selectedTab)
        }
        // --- FEEDBACK SENSORIAL (Consumiendo del ViewModel) ---
        .sensoryFeedback(.impact(weight: .medium), trigger: viewModel.saveTrigger)
        .sensoryFeedback(.selection, trigger: viewModel.inputValue)
        
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
            // Fondo dinámico gestionado por el ViewModel
            LinearGradient(
                gradient: Gradient(colors: viewModel.backgroundGradient(isDark: colorScheme == .dark)),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            .animation(.easeInOut(duration: 0.5), value: viewModel.inputValue)

            VStack(spacing: 28) {
                Spacer()

                // MARK: - Ícono de estado térmico
                Image(systemName: viewModel.iconName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .foregroundStyle(viewModel.iconColor)
                    .shadow(color: viewModel.iconColor.opacity(0.5), radius: 10)
                    .scaleEffect(viewModel.iconAnimationScale)
                    .animation(.spring(response: 0.6, dampingFraction: 0.5), value: viewModel.iconName)

                // MARK: - Resultado y Botón de Guardado
                VStack(spacing: 15) {
                    Text("\(viewModel.inputValue, specifier: "%.1f")° \(viewModel.unitSelection == 0 ? "C" : "F") = \(viewModel.convertedValue, specifier: "%.1f")° \(viewModel.unitSelection == 0 ? "F" : "C")")
                        .font(.title2)
                        .bold()
                        .multilineTextAlignment(.center)
                        .contentTransition(.numericText())
                        .animation(.snappy, value: viewModel.inputValue)

                    Button(action: {
                        // Delegamos la lógica de guardado al ViewModel
                        viewModel.saveConversion(modelContext: modelContext, history: history)
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
                Text(viewModel.temperatureDescription)
                    .font(.headline)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(.ultraThinMaterial)
                    .cornerRadius(16)
                    .shadow(radius: 4)

                // MARK: - Control deslizante
                VStack(spacing: 8) {
                    Slider(value: $viewModel.inputValue, in: -50...50)
                        .tint(viewModel.iconColor)
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
