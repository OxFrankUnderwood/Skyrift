//
//  SkyriftWidgetLiveActivity.swift
//  SkyriftWidget
//
//  Created by Emre on 26.02.2026.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct SkyriftWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct SkyriftWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: SkyriftWidgetAttributes.self) { context in
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

extension SkyriftWidgetAttributes {
    fileprivate static var preview: SkyriftWidgetAttributes {
        SkyriftWidgetAttributes(name: "World")
    }
}

extension SkyriftWidgetAttributes.ContentState {
    fileprivate static var smiley: SkyriftWidgetAttributes.ContentState {
        SkyriftWidgetAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: SkyriftWidgetAttributes.ContentState {
         SkyriftWidgetAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: SkyriftWidgetAttributes.preview) {
   SkyriftWidgetLiveActivity()
} contentStates: {
    SkyriftWidgetAttributes.ContentState.smiley
    SkyriftWidgetAttributes.ContentState.starEyes
}
