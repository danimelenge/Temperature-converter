//
//  HistoryListView.swift
//  Temperature converter
//
//  Created by Daniel Melenge Rojas on 20/01/26.
//

import SwiftUI
import SwiftData

struct HistoryListView: View {
    // MARK: - Entorno y Datos
    @Environment(\.modelContext) private var modelContext
    @Environment(\.colorScheme) var colorScheme
    @Query(sort: \ConversionHistory.timestamp, order: .reverse) var history: [ConversionHistory]
    
    // Estado para controlar la notificación visual
    @State private var showToast = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                // 1. Fondo Adaptativo
                Group {
                    if colorScheme == .dark {
                        Color(red: 0.02, green: 0.03, blue: 0.08)
                    } else {
                        Color.orange.opacity(0.05)
                    }
                }
                .ignoresSafeArea()
                
                if history.isEmpty {
                    ContentUnavailableView(
                        "Sin historial",
                        systemImage: "clock.arrow.circlepath",
                        description: Text("Las conversiones que guardes aparecerán aquí.")
                    )
                    // ACCESIBILIDAD: Ya viene optimizado por Apple, pero nos aseguramos de que sea el foco principal.
                } else {
                    List {
                        ForEach(history) { item in
                            historyRow(item)
                                .listRowBackground(Color.primary.opacity(0.06))
                        }
                        .onDelete(perform: deleteItems)
                    }
                    .scrollContentBackground(.hidden)
                }
                
                // --- NOTIFICACIÓN VISUAL (TOAST) ---
                if showToast {
                    VStack {
                        Spacer()
                        HStack(spacing: 10) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(.green)
                            Text("Copiado al portapapeles")
                                .font(.subheadline)
                                .bold()
                                .foregroundStyle(.primary)
                        }
                        .padding(.vertical, 12)
                        .padding(.horizontal, 20)
                        .background(.ultraThinMaterial)
                        .clipShape(Capsule())
                        .overlay(
                            Capsule()
                                .stroke(Color.primary.opacity(0.1), lineWidth: 0.5)
                        )
                        .shadow(color: Color.black.opacity(0.15), radius: 10, x: 0, y: 5)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                        .padding(.bottom, 40)
                    }
                    .zIndex(1)
                    // ACCESIBILIDAD: Añadimos un área de anuncio para que VoiceOver lo lea al aparecer
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel("Notificación: Copiado al portapapeles")
                }
            }
            .navigationTitle("Historial")
            .toolbar {
                if !history.isEmpty {
                    EditButton()
                        .tint(.orange)
                        .accessibilityLabel("Editar lista de historial")
                }
            }
        }
    }
    
    // MARK: - Subvista para la fila
    @ViewBuilder
    private func historyRow(_ item: ConversionHistory) -> some View {
        let shareText = "\(String(format: "%.1f", item.inputAmount))°\(item.inputUnit) equivalen a \(String(format: "%.1f", item.resultAmount))°\(item.resultUnit)"
        
        // ACCESIBILIDAD: Convertimos la fila en un solo elemento para evitar navegación fragmentada
        HStack(spacing: 12) {
            HStack { // Contenedor de la información de conversión
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(item.inputAmount, specifier: "%.1f")°\(item.inputUnit)")
                        .font(.headline)
                    
                    HStack(spacing: 4) {
                        Text(item.timestamp, style: .date)
                        Text("•")
                        Text(item.timestamp, style: .time)
                    }
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "arrow.right.circle.fill")
                    .foregroundStyle(.orange)
                    .font(.title3)
                    .accessibilityHidden(true) // Ocultamos el icono decorativo
                
                Spacer()
                
                Text("\(item.resultAmount, specifier: "%.1f")°\(item.resultUnit)")
                    .font(.body)
                    .bold()
            }
            .accessibilityElement(children: .combine) // Agrupa textos e ignorar el icono
            .accessibilityLabel("\(item.inputAmount, specifier: "%.1f") grados \(item.inputUnit) equivalen a \(item.resultAmount, specifier: "%.1f") grados \(item.resultUnit). Guardado el \(item.timestamp.formatted(date: .long, time: .shortened))")
            
            // El menú se mantiene como elemento separado para poder interactuar
            Menu {
                Button {
                    UIPasteboard.general.string = shareText
                    triggerToast()
                } label: {
                    Label("Copiar resultado", systemImage: "doc.on.doc")
                }
                
                ShareLink(item: shareText, subject: Text("Conversión de Temperatura")) {
                    Label("Compartir", systemImage: "square.and.arrow.up")
                }
            } label: {
                Image(systemName: "ellipsis.circle")
                    .font(.title3)
                    .foregroundStyle(.orange)
                    .padding(.leading, 8)
                    .contentShape(Rectangle()) // Aumenta el área de toque
            }
            .accessibilityLabel("Opciones de registro")
            .accessibilityHint("Permite copiar o compartir esta conversión.")
            .buttonStyle(.borderless)
        }
        .padding(.vertical, 4)
    }
    
    // MARK: - Lógica de Notificación
    private func triggerToast() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        
        // ACCESIBILIDAD: Notificamos a VoiceOver explícitamente que algo ocurrió
        UIAccessibility.post(notification: .announcement, argument: "Copiado al portapapeles")
        
        withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
            showToast = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation(.easeInOut) {
                showToast = false
            }
        }
    }
    
    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(history[index])
            }
            try? modelContext.save()
        }
    }
}

// MARK: - Previews
#Preview("Light Mode") {
    let container = try! ModelContainer(for: ConversionHistory.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
    container.mainContext.insert(ConversionHistory(inputAmount: 20, inputUnit: "C", resultAmount: 68, resultUnit: "F"))
    
    return HistoryListView()
        .modelContainer(container)
        .preferredColorScheme(.light)
}

#Preview("Dark Mode") {
    let container = try! ModelContainer(for: ConversionHistory.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
    container.mainContext.insert(ConversionHistory(inputAmount: -5, inputUnit: "C", resultAmount: 23, resultUnit: "F"))
    
    return HistoryListView()
        .modelContainer(container)
        .preferredColorScheme(.dark)
}
