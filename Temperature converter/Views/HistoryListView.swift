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
    @Environment(\.colorScheme) var colorScheme // Detecta automáticamente el tema
    @Query(sort: \ConversionHistory.timestamp, order: .reverse) var history: [ConversionHistory]
    
    var body: some View {
        NavigationStack {
            ZStack {
                // 1. Fondo Adaptativo: Azul marino profundo en Oscuro, Naranja muy suave en Claro
                Group {
                    if colorScheme == .dark {
                        Color(red: 0.02, green: 0.03, blue: 0.08) // Tu azul marino profundo
                    } else {
                        Color.orange.opacity(0.05) // Fondo claro con un toque cálido
                    }
                }
                .ignoresSafeArea()
                
                if history.isEmpty {
                    ContentUnavailableView(
                        "Sin historial",
                        systemImage: "clock.arrow.circlepath",
                        description: Text("Las conversiones que guardes aparecerán aquí.")
                    )
                } else {
                    List {
                        ForEach(history) { item in
                            historyRow(item)
                                // 2. Fondo de Celda Adaptativo:
                                // Usamos 'primary' con poca opacidad para que sea grisáceo en ambos modos
                                .listRowBackground(Color.primary.opacity(0.06))
                        }
                        .onDelete(perform: deleteItems)
                    }
                    .scrollContentBackground(.hidden) // Oculta el fondo gris por defecto de la lista
                }
            }
            .navigationTitle("Historial")
            .toolbar {
                if !history.isEmpty {
                    EditButton()
                        .tint(.orange)
                }
            }
        }
    }
    
    // MARK: - Subvista para la fila (Optimizada para contraste)
    @ViewBuilder
    private func historyRow(_ item: ConversionHistory) -> some View {
        HStack(spacing: 15) {
            VStack(alignment: .leading, spacing: 4) {
                // Texto principal: .primary cambia automáticamente entre blanco y negro
                Text("\(item.inputAmount, specifier: "%.1f")°\(item.inputUnit)")
                    .font(.headline)
                    .foregroundStyle(.primary)
                
                // Fecha y hora: .secondary es un gris que se adapta a ambos fondos
                HStack(spacing: 4) {
                    Text(item.timestamp, style: .date)
                    Text("•")
                    Text(item.timestamp, style: .time)
                }
                .font(.caption2)
                .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            // Icono de acento (naranja resalta bien en azul oscuro y en fondo claro)
            Image(systemName: "arrow.right.circle.fill")
                .foregroundStyle(.orange)
                .font(.title2)
            
            Spacer()
            
            // Resultado
            Text("\(item.resultAmount, specifier: "%.1f")°\(item.resultUnit)")
                .font(.title3)
                .bold()
                .foregroundStyle(.primary)
        }
        .padding(.vertical, 4)
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

// MARK: - Previews para probar ambos modos
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
