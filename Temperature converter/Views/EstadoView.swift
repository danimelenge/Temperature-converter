//
//  EstadoView.swift
//  Temperature converter
//
//  Created by Daniel Melenge Rojas on 21/07/25.
//

import SwiftUI

struct EstadoView: View {
    let celsius: Double

    private var icon: String {
        switch celsius {
        case ..<0: return "snow"
        case 0..<25: return "thermometer"
        default: return "flame"
        }
    }

    private var estado: String {
        switch celsius {
        case ..<0: return "Muy frío"
        case 0..<10: return "Frío"
        case 10..<25: return "Templado"
        case 25..<35: return "Caliente"
        default: return "Muy caliente"
        }
    }

    private var color: Color {
        switch celsius {
        case ..<0: return .blue
        case 0..<25: return .gray
        case 25..<35: return .orange
        default: return .red
        }
    }

    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            Image(systemName: icon)
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .foregroundColor(color)
                .scaleEffect(celsius > 35 ? 1.2 : 1.0)
                .animation(.spring(), value: celsius)

            Text(estado)
                .font(.largeTitle)
                .bold()
                .foregroundColor(color)

            Text("Temperatura actual: \(celsius, specifier: "%.1f")°C")
                .font(.title3)
                .foregroundColor(.secondary)

            Spacer()
        }
        .padding()
        .navigationTitle("Estado Actual")
    }
}
