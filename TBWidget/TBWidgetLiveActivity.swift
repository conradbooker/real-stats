//
//  TBWidgetLiveActivity.swift
//  TBWidget
//
//  Created by Conrad on 6/25/24.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct TBWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct TBWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: TBWidgetAttributes.self) { context in
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

extension TBWidgetAttributes {
    fileprivate static var preview: TBWidgetAttributes {
        TBWidgetAttributes(name: "World")
    }
}

extension TBWidgetAttributes.ContentState {
    fileprivate static var smiley: TBWidgetAttributes.ContentState {
        TBWidgetAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: TBWidgetAttributes.ContentState {
         TBWidgetAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: TBWidgetAttributes.preview) {
   TBWidgetLiveActivity()
} contentStates: {
    TBWidgetAttributes.ContentState.smiley
    TBWidgetAttributes.ContentState.starEyes
}
