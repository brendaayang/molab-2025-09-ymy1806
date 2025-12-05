//
//  FlavorlyWidgetsLiveActivity.swift
//  FlavorlyWidgets
//
//  Created by Brenda Yang on 10/18/25.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct FlavorlyWidgetsAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct FlavorlyWidgetsLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: FlavorlyWidgetsAttributes.self) { context in
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

extension FlavorlyWidgetsAttributes {
    fileprivate static var preview: FlavorlyWidgetsAttributes {
        FlavorlyWidgetsAttributes(name: "World")
    }
}

extension FlavorlyWidgetsAttributes.ContentState {
    fileprivate static var smiley: FlavorlyWidgetsAttributes.ContentState {
        FlavorlyWidgetsAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: FlavorlyWidgetsAttributes.ContentState {
         FlavorlyWidgetsAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: FlavorlyWidgetsAttributes.preview) {
   FlavorlyWidgetsLiveActivity()
} contentStates: {
    FlavorlyWidgetsAttributes.ContentState.smiley
    FlavorlyWidgetsAttributes.ContentState.starEyes
}
