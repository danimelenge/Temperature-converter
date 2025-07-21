//
//  SettingsView.swift
//  Temperature converter
//
//  Created by Daniel Melenge Rojas on 21/07/25.
//

import SwiftUI

struct SettingsView: View {
    @AppStorage("unitSelection") private var unitSelection: Int = 0

    var body: some View {
        Form {
            Section(header: Text("Unidad de conversión")) {
                Picker("Conversión", selection: $unitSelection) {
                    Text("Celsius → Fahrenheit").tag(0)
                    Text("Fahrenheit → Celsius").tag(1)
                }
                .pickerStyle(.segmented)
            }
        }
        .navigationTitle("Ajustes")
    }
}
