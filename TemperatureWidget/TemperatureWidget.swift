//
//  TemperatureWidget.swift
//  TemperatureWidget
//
//  Created by Daniel Melenge Rojas on 21/05/26.
//

import WidgetKit
import SwiftUI

// 1. EL MODELO DE DATOS
struct SimpleEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationAppIntent // Enlace con la configuración del sistema
    let inputAmount: Double
    let inputUnit: String
    let resultAmount: Double
    let resultUnit: String
    let icon: String
}

// 2. EL PROVEEDOR (PROVIDER) - Exclusivo para el ciclo de vida del Widget en Home Screen
struct Provider: AppIntentTimelineProvider {
    // Vista de carga inicial simulada
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), configuration: ConfigurationAppIntent(), inputAmount: 20, inputUnit: "C", resultAmount: 68, resultUnit: "F", icon: "thermometer.medium")
    }

    // Vista rápida para la galería de widgets del iPhone
    func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> SimpleEntry {
        SimpleEntry(date: Date(), configuration: configuration, inputAmount: 20, inputUnit: "C", resultAmount: 68, resultUnit: "F", icon: "thermometer.medium")
    }

    // Genera el horario de actualizaciones estáticas en segundo plano
    func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<SimpleEntry> {
        let entry = SimpleEntry(
            date: Date(),
            configuration: configuration,
            inputAmount: 0,
            inputUnit: "C",
            resultAmount: 32,
            resultUnit: "F",
            icon: "snowflake"
        )
        
        return Timeline(entries: [entry], policy: .atEnd)
    }
}

// 3. EL DISEÑO VISUAL ADAPTADO A LA INTERFAZ DE TU APP
struct TemperatureWidgetEntryView : View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var family

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Cabecera del Widget
            HStack(spacing: 6) {
                Image(systemName: entry.icon)
                    .font(.title3)
                    .foregroundStyle(.orange)
                
                // Xcode extraerá "Conversor" automáticamente
                Text("Conversor")
                    .font(.caption.bold())
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            // Cuerpo Principal (Visualización del cálculo)
            VStack(alignment: .leading, spacing: 2) {
                Text("\(entry.inputAmount, specifier: "%.0f")°\(entry.inputUnit)")
                    .font(.subheadline.bold())
                    .foregroundStyle(.secondary)
                
                // TEXTO MODIFICADO CON ACCESIBILIDAD AUTOMÁTICA
                Text("\(entry.resultAmount, specifier: "%.1f")°\(entry.resultUnit)")
                    .font(.system(size: family == .systemMedium ? 36 : 28, weight: .black, design: .rounded))
                    .foregroundStyle(LinearGradient(colors: [.orange, .red], startPoint: .top, endPoint: .bottom))
                    .lineLimit(1) // 1. Evitamos que el texto ocupe más de una línea o muestre "..."
                    .minimumScaleFactor(0.5) // 2. Permite encogerse de forma fluida hasta la mitad de su tamaño
            }
            
            Spacer()
            
            // Pie de página con estampa de tiempo localizada
            HStack {
                Spacer()
                // Xcode extraerá esto como "Actualizado: %@" de forma automática
                Text("Actualizado: \(entry.date, style: .time)")
                    .font(.system(size: 8, weight: .medium))
                    .foregroundStyle(.tertiary)
            }
        }
        .containerBackground(for: .widget) {
            // Usa el color adaptable de tus Assets (Claro / Oscuro)
            Color("WidgetBackground")
        }
    }
}

// 4. CONFIGURACIÓN GENERAL DEL WIDGET
struct TemperatureWidget: Widget {
    let kind: String = "TemperatureWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: ConfigurationAppIntent.self, provider: Provider()) { entry in
            TemperatureWidgetEntryView(entry: entry)
        }
        // Textos de la galería de widgets localizados automáticamente
        .configurationDisplayName("Última conversión")
        .description("Revisa de un vistazo el último cálculo guardado en tu historial.")
        .supportedFamilies([.systemSmall, .systemMedium]) // Bloqueado para evitar pantallas dinámicas grandes
    }
}

// MOCK DE INTENCIONES PARA RENDERIZADO
extension ConfigurationAppIntent {
    fileprivate static var dummyConfig: ConfigurationAppIntent {
        let intent = ConfigurationAppIntent()
        return intent
    }
}

// VISTA PREVIA (CANVAS)
#Preview(as: .systemSmall) {
    TemperatureWidget()
} timeline: {
    SimpleEntry(date: .now, configuration: .dummyConfig, inputAmount: 25, inputUnit: "C", resultAmount: 77, resultUnit: "F", icon: "thermometer.sun.fill")
    SimpleEntry(date: .now, configuration: .dummyConfig, inputAmount: -5, inputUnit: "C", resultAmount: 23, resultUnit: "F", icon: "snowflake")
}
