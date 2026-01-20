//
//  HistoryListView.swift
//  Temperature converter
//
//  Created by Daniel Melenge Rojas on 20/01/26.
//

import SwiftUI
import SwiftData

struct HistoryListView: View {
    // MARK: - SwiftData Query
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \ConversionHistory.timestamp, order: .reverse) var history: [ConversionHistory]
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Fondo para mantener la estética de la app
                Color.orange.opacity(0.05).ignoresSafeArea()
                
                if history.isEmpty {
                    // Estado vacío usando ContentUnavailableView (iOS 17+)
                    ContentUnavailableView(
                        "Sin historial",
                        systemImage: "clock.arrow.circlepath",
                        description: Text("Las conversiones que guardes aparecerán aquí.")
                    )
                } else {
                    List {
                        ForEach(history) { item in
                            historyRow(item)
                                .listRowBackground(Color.white.opacity(0.5))
                        }
                        .onDelete(perform: deleteItems) // Permite deslizar para borrar
                    }
                    .scrollContentBackground(.hidden) // Oculta el fondo gris estándar de la List
                }
            }
            .navigationTitle("Historial")
            .toolbar {
                if !history.isEmpty {
                    EditButton() // Botón para borrar varios a la vez
                }
            }
        }
    }
    
    // MARK: - Subvista para la fila
    @ViewBuilder
    private func historyRow(_ item: ConversionHistory) -> some View {
        HStack(spacing: 15) {
            VStack(alignment: .leading, spacing: 4) {
                Text("\(item.inputAmount, specifier: "%.1f")°\(item.inputUnit)")
                    .font(.headline)
                
                Text(item.timestamp, style: .date)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                Text(item.timestamp, style: .time)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            Image(systemName: "arrow.right.circle.fill")
                .foregroundStyle(.orange)
                .font(.title2)
            
            Spacer()
            
            Text("\(item.resultAmount, specifier: "%.1f")°\(item.resultUnit)")
                .font(.title3)
                .bold()
                .foregroundStyle(.primary)
        }
        .padding(.vertical, 4)
    }
    
    // MARK: - Funciones
    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(history[index])
            }
            try? modelContext.save()
        }
    }
}

// MARK: - Preview con SwiftData Mock
#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: ConversionHistory.self, configurations: config)
    
    // Añadimos datos de ejemplo para ver cómo queda en el Preview
    let example = ConversionHistory(inputAmount: 25, inputUnit: "C", resultAmount: 77, resultUnit: "F")
    container.mainContext.insert(example)
    
    return HistoryListView()
        .modelContainer(container)
}

