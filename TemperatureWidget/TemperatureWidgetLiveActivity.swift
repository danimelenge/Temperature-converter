//
//  TemperatureWidgetLiveActivity.swift
//  TemperatureWidget
//
//  Created by Daniel Melenge Rojas on 20/05/26.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct TemperatureWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct TemperatureWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: TemperatureWidgetAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                Text("Hello \(context.state.emoji)")
            }
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text("Leading")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Bottom \(context.state.emoji)")
                    // more content
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T \(context.state.emoji)")
            } minimal: {
                Text(context.state.emoji)
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

extension TemperatureWidgetAttributes {
    fileprivate static var preview: TemperatureWidgetAttributes {
        TemperatureWidgetAttributes(name: "World")
    }
}

extension TemperatureWidgetAttributes.ContentState {
    fileprivate static var smiley: TemperatureWidgetAttributes.ContentState {
        TemperatureWidgetAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: TemperatureWidgetAttributes.ContentState {
         TemperatureWidgetAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: TemperatureWidgetAttributes.preview) {
   TemperatureWidgetLiveActivity()
} contentStates: {
    TemperatureWidgetAttributes.ContentState.smiley
    TemperatureWidgetAttributes.ContentState.starEyes
}
