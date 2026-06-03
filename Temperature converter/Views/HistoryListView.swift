//
//  HistoryListView.swift
//  Temperature converter
//
//  Created by Daniel Melenge Rojas.
//

import SwiftUI
import SwiftData
import Charts // Framework para los gráficos dinámicos

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
                // 1. Fondo Adaptativo Personalizado
                Group {
                    if colorScheme == .dark {
                        Color(red: 0.02, green: 0.03, blue: 0.08)
                    } else {
                        Color.orange.opacity(0.05)
                    }
                }
                .ignoresSafeArea()
                
                // 2. Control de Estado de la Pantalla
                if history.isEmpty {
                    ContentUnavailableView(
                        "Sin historial",
                        systemImage: "clock.arrow.circlepath",
                        description: Text("Las conversiones que guardes aparecerán aquí.")
                    )
                } else {
                    List {
                        // MARK: - SECCIÓN 1: GRÁFICO DE TENDENCIA (Swift Charts)
                        Section {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Tendencia de Entradas")
                                    .font(.caption.bold())
                                    .foregroundStyle(.secondary)
                                
                                Chart {
                                    // Tomamos los últimos 10 registros y los revertimos para orden cronológico (Izquierda a Derecha)
                                    ForEach(history.prefix(10).reversed()) { item in
                                        // Línea principal del gráfico
                                        LineMark(
                                            x: .value("Fecha", item.timestamp),
                                            y: .value("Temperatura", item.inputAmount)
                                        )
                                        .foregroundStyle(Color.orange.gradient)
                                        .interpolationMethod(.catmullRom) // Curvatura estilizada premium
                                        
                                        // Puntos de intersección
                                        PointMark(
                                            x: .value("Fecha", item.timestamp),
                                            y: .value("Temperatura", item.inputAmount)
                                        )
                                        .foregroundStyle(.orange)
                                    }
                                }
                                .frame(height: 150)
                                // Optimización de ejes para consistencia visual
                                .chartXAxis {
                                    AxisMarks(values: .stride(by: .day)) { _ in
                                        AxisGridLine()
                                        AxisValueLabel(format: .dateTime.day().month())
                                            .font(.caption2)
                                    }
                                }
                                .chartYAxis {
                                    AxisMarks { value in
                                        AxisGridLine()
                                        if let temp = value.as(Double.self) {
                                            AxisValueLabel("\(Int(temp))°")
                                                .font(.caption2)
                                        }
                                    }
                                }
                            }
                            .padding(.vertical, 8)
                        }
                        .listRowBackground(Color.clear) // Permite que el gráfico flote sobre tu fondo adaptativo
                        
                        // MARK: - SECCIÓN 2: LISTA DEL HISTORIAL
                        Section(header: Text("Registros Guardados")) {
                            ForEach(history) { item in
                                historyRow(item)
                                    .listRowBackground(Color.primary.opacity(0.06))
                            }
                            .onDelete(perform: deleteItems)
                        }
                    }
                    .scrollContentBackground(.hidden) // Oculta el fondo nativo para ver tus colores personalizados
                }
                
                // MARK: - 3. NOTIFICACIÓN VISUAL (TOAST)
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
    
    // MARK: - Subvista para la fila (historyRow)
    @ViewBuilder
    private func historyRow(_ item: ConversionHistory) -> some View {
        let shareText = "\(String(format: "%.1f", item.inputAmount))°\(item.inputUnit) equivalen a \(String(format: "%.1f", item.resultAmount))°\(item.resultUnit)"
        
        HStack(spacing: 12) {
            HStack {
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
                    .accessibilityHidden(true)
                
                Spacer()
                
                Text("\(item.resultAmount, specifier: "%.1f")°\(item.resultUnit)")
                    .font(.body)
                    .bold()
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel("\(item.inputAmount, specifier: "%.1f") grados \(item.inputUnit) equivalen a \(item.resultAmount, specifier: "%.1f") grados \(item.resultUnit). Guardado el \(item.timestamp.formatted(date: .long, time: .shortened))")
            
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
                    .contentShape(Rectangle())
            }
            .accessibilityLabel("Opciones de registro")
            .accessibilityHint("Permite copiar o compartir esta conversión.")
            .buttonStyle(.borderless)
        }
        .padding(.vertical, 4)
    }
    
    // MARK: - Lógica de Control y Notificaciones
    private func triggerToast() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        
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

// MARK: - Previews de Desarrollo Corregidos
#Preview("Light Mode") {
    let container = try! ModelContainer(for: ConversionHistory.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
    
    // Instanciamos y luego asignamos el desfase de tiempo manualmente
    let registro1 = ConversionHistory(inputAmount: 12, inputUnit: "C", resultAmount: 53.6, resultUnit: "F")
    registro1.timestamp = Date().addingTimeInterval(-86400 * 3) // Hace 3 días
    
    let registro2 = ConversionHistory(inputAmount: 28, inputUnit: "C", resultAmount: 82.4, resultUnit: "F")
    registro2.timestamp = Date().addingTimeInterval(-86400 * 2) // Hace 2 días
    
    let registro3 = ConversionHistory(inputAmount: -5, inputUnit: "C", resultAmount: 23.0, resultUnit: "F")
    registro3.timestamp = Date().addingTimeInterval(-86400 * 1) // Hace 1 día
    
    let registro4 = ConversionHistory(inputAmount: 20, inputUnit: "C", resultAmount: 68.0, resultUnit: "F")
    // Este toma la fecha actual por defecto de tu modelo
    
    // Insertamos los registros preparados en el contexto
    container.mainContext.insert(registro1)
    container.mainContext.insert(registro2)
    container.mainContext.insert(registro3)
    container.mainContext.insert(registro4)
    
    return HistoryListView()
        .modelContainer(container)
        .preferredColorScheme(.light)
}

#Preview("Dark Mode") {
    let container = try! ModelContainer(for: ConversionHistory.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
    
    let registro1 = ConversionHistory(inputAmount: 35, inputUnit: "C", resultAmount: 95.0, resultUnit: "F")
    registro1.timestamp = Date().addingTimeInterval(-86400 * 2)
    
    let registro2 = ConversionHistory(inputAmount: 15, inputUnit: "C", resultAmount: 59.0, resultUnit: "F")
    registro2.timestamp = Date().addingTimeInterval(-86400 * 1)
    
    let registro3 = ConversionHistory(inputAmount: -2, inputUnit: "C", resultAmount: 28.4, resultUnit: "F")
    
    container.mainContext.insert(registro1)
    container.mainContext.insert(registro2)
    container.mainContext.insert(registro3)
    
    return HistoryListView()
        .modelContainer(container)
        .preferredColorScheme(.dark)
}
