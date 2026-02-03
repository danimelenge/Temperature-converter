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
                        .background(.ultraThinMaterial) // Efecto cristal adaptativo
                        .clipShape(Capsule())
                        .overlay(
                            Capsule()
                                .stroke(Color.primary.opacity(0.1), lineWidth: 0.5)
                        )
                        .shadow(color: Color.black.opacity(0.15), radius: 10, x: 0, y: 5)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                        .padding(.bottom, 40)
                    }
                    .zIndex(1) // Asegura que flote sobre la lista
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
    
    // MARK: - Subvista para la fila
    @ViewBuilder
    private func historyRow(_ item: ConversionHistory) -> some View {
        let shareText = "\(String(format: "%.1f", item.inputAmount))°\(item.inputUnit) equivalen a \(String(format: "%.1f", item.resultAmount))°\(item.resultUnit)"
        
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text("\(item.inputAmount, specifier: "%.1f")°\(item.inputUnit)")
                    .font(.headline)
                    .foregroundStyle(.primary)
                
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
            
            Spacer()
            
            Text("\(item.resultAmount, specifier: "%.1f")°\(item.resultUnit)")
                .font(.body)
                .bold()
                .foregroundStyle(.primary)
            
            Menu {
                Button {
                    UIPasteboard.general.string = shareText
                    triggerToast() // Activa el mensaje visual
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
            }
            .buttonStyle(.borderless)
        }
        .padding(.vertical, 4)
    }
    
    // MARK: - Lógica de Notificación
    private func triggerToast() {
        // Feedback físico (Vibración)
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        
        withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
            showToast = true
        }
        
        // Desaparece automáticamente tras 2 segundos
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
