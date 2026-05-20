//
//  TemperatureWidgetBundle.swift
//  TemperatureWidget
//
//  Created by Daniel Melenge Rojas on 20/05/26.
//

import WidgetKit
import SwiftUI

@main
struct TemperatureWidgetBundle: WidgetBundle {
    var body: some Widget {
        TemperatureWidget()
        TemperatureWidgetLiveActivity()
    }
}
