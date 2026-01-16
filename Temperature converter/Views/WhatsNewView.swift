//
//  WhatsNewView.swift
//  Temperature converter
//
//  Created by Daniel Melenge Rojas on 16/01/26.
//

import SwiftUI

struct WhatsNewView: View {
    @Environment(\.dismiss) var dismiss
    
    // Control de animaciones
    @State private var isAnimating: Bool = false
    
    var body: some View {
        VStack {
            // 1. Título y Cabecera
            ScrollView {
                VStack(spacing: 30) {
                    Text("Novedades en\nTemperature Converter")
                        .font(.system(size: 34, weight: .bold))
                        .multilineTextAlignment(.center)
                        .padding(.top, 50)
                        .opacity(isAnimating ? 1 : 0)
                        .offset(y: isAnimating ? 0 : 20)
                    
                    // 2. Lista de Características (Features)
                    VStack(alignment: .leading, spacing: 25) {
                        FeatureRow(
                            icon: "thermometer.sun.fill",
                            color: .orange,
                            title: "Nuevas Unidades",
                            description: "Ahora soportamos Rankine y Réaumur para conversiones más científicas."
                        )
                        
                        FeatureRow(
                            icon: "arrow.triangle.2.circlepath",
                            color: .blue,
                            title: "Conversión Instantánea",
                            description: "Los valores se actualizan en tiempo real mientras escribes, sin demoras."
                        )
                        
                        FeatureRow(
                            icon: "paintpalette.fill",
                            color: .purple,
                            title: "Diseño Renovado",
                            description: "Una interfaz más limpia y moderna que se adapta al modo oscuro automáticamente."
                        )
                    }
                    .padding(.horizontal)
                    .opacity(isAnimating ? 1 : 0)
                    .offset(y: isAnimating ? 0 : 30)
                    .animation(.easeOut(duration: 0.8).delay(0.2), value: isAnimating)
                }
            }
            
            Spacer()
            
            // 3. Botón Continuar
            Button(action: {
                // Haptic feedback (opcional)
                let generator = UIImpactFeedbackGenerator(style: .medium)
                generator.impactOccurred()
                
                dismiss()
            }) {
                Text("Continuar")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(14)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
            .opacity(isAnimating ? 1 : 0)
            .offset(y: isAnimating ? 0 : 50)
            .animation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.5), value: isAnimating)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.8)) {
                isAnimating = true
            }
        }
    }
}

// Componente reutilizable para cada fila de novedad
struct FeatureRow: View {
    let icon: String
    let color: Color
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 30))
                .foregroundColor(color)
                .frame(width: 40)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}

#Preview  {
        WhatsNewView()
    }

