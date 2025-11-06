//
//  MainTabView.swift
//  Temperature converter
//
//  Created by Daniel Melenge Rojas on 6/11/25.
//

/*import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0

    var body: some View {
        ZStack {
            // Fondo degradado
            LinearGradient(
                gradient: Gradient(colors: [.blue.opacity(0.2), .orange.opacity(0.2)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            // TabView con animación
            TabView(selection: $selectedTab) {
                ContentView()
                    .tabItem {
                        Label("Convertir", systemImage: "thermometer.sun")
                    }
                    .tag(0)

                SettingsView()
                    .tabItem {
                        Label("Ajustes", systemImage: "gearshape")
                    }
                    .tag(1)
            }
            .tint(.orange)
            .animation(.easeInOut(duration: 0.3), value: selectedTab)
            .onChange(of: selectedTab) { _, _ in
                print("Cambio de tab a \(selectedTab)")
            }
        }
    }
}

#Preview {
    MainTabView()
}

 */
