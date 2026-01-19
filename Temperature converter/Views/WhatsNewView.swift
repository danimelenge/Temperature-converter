//
//  WhatsNewView.swift
//  Temperature converter
//
//  Created by Daniel Melenge Rojas on 16/01/26.
//

import SwiftUI

struct WhatsNewView: View {
    @Environment(\.dismiss) var dismiss
    
    // Control de animaciones individuales para efecto escalonado
    @State private var animateTitle = false
    @State private var animateFeatures = false
    @State private var animateButton = false
    
    var body: some View {
        VStack {
            ScrollView {
                VStack(spacing: 40) {
                    // 1. Título y Cabecera con Gradiente
                    VStack(spacing: 8) {
                        Text("Novedades en")
                            .font(.title2)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                        
                        Text("Temperature Converter")
                            .font(.system(size: 36, weight: .black, design: .rounded))
                            .multilineTextAlignment(.center)
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.blue, .purple],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                    }
                    .padding(.top, 60)
                    .scaleEffect(animateTitle ? 1 : 0.8)
                    .opacity(animateTitle ? 1 : 0)
                    
                    // 2. Lista de Características (Features)
                    VStack(alignment: .leading, spacing: 32) {
                        FeatureRow(
                            icon: "thermometer.sun.fill",
                            color: .orange,
                            title: "Nuevas Unidades",
                            description: "Ahora soportamos Rankine y Réaumur para conversiones más científicas.",
                            delay: 0.3
                        )
                        
                        FeatureRow(
                            icon: "arrow.triangle.2.circlepath",
                            color: .blue,
                            title: "Conversión Instantánea",
                            description: "Los valores se actualizan en tiempo real mientras escribes, sin demoras.",
                            delay: 0.5
                        )
                        
                        FeatureRow(
                            icon: "paintpalette.fill",
                            color: .purple,
                            title: "Diseño Renovado",
                            description: "Una interfaz más limpia y moderna que se adapta al modo oscuro automáticamente.",
                            delay: 0.7
                        )
                    }
                    .padding(.horizontal, 30)
                }
            }
            
            Spacer()
            
            // 3. Botón Continuar Estilizado
            Button(action: {
                let generator = UIImpactFeedbackGenerator(style: .heavy)
                generator.impactOccurred()
                dismiss()
            }) {
                Text("Continuar")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .fill(LinearGradient(colors: [.blue, .blue.opacity(0.8)], startPoint: .top, endPoint: .bottom))
                            .shadow(color: .blue.opacity(0.3), radius: 10, x: 0, y: 5)
                    )
            }
            .padding(.horizontal, 30)
            .padding(.bottom, 40)
            .scaleEffect(animateButton ? 1 : 0.9)
            .opacity(animateButton ? 1 : 0)
        }
        .onAppear {
            // Animación de entrada por etapas
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.1)) {
                animateTitle = true
            }
            
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.8)) {
                animateButton = true
            }
        }
    }
}

// Componente de fila con animación individual interna
struct FeatureRow: View {
    let icon: String
    let color: Color
    let title: String
    let description: String
    let delay: Double
    
    @State private var isVisible = false
    
    var body: some View {
        HStack(alignment: .top, spacing: 20) {
            Image(systemName: icon)
                .font(.system(size: 32))
                .foregroundColor(color)
                .frame(width: 45)
                // Efecto de símbolo (iOS 17+)
                .symbolEffect(.bounce, value: isVisible)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .fontWeight(.bold)
                
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineSpacing(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .offset(x: isVisible ? 0 : 20)
        .opacity(isVisible ? 1 : 0)
        .onAppear {
            withAnimation(.easeOut(duration: 0.5).delay(delay)) {
                isVisible = true
            }
        }
    }
}

#Preview {
    WhatsNewView()
}
