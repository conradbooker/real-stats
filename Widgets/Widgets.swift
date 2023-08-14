//
//  Widgets.swift
//  Widgets
//
//  Created by Conrad on 4/6/23.
//

import WidgetKit
import SwiftUI
import Intents
//import WrappingHStack

struct CButton: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.9 : 1)
    }
}

struct Provider: IntentTimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), configuration: ConfigurationIntent())
    }

    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), configuration: configuration)
        completion(entry)
    }

    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [SimpleEntry] = []

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = SimpleEntry(date: entryDate, configuration: configuration)
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

enum WidgetType {
    case small
    case medium
    case large
}

struct WidgetSmallTime: View {
    var line: String
    var time: String

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .foregroundColor(Color("cLessDarkGray"))
                .shadow(radius: 2)
            HStack(spacing: 0) {
                Image(line)
                    .interpolation(.high)
                    .resizable()
                    .frame(width: 15, height: 15)
                    .padding(.leading,2)
                Spacer()
                    .frame(width: 5)
                VStack {
                    Text("\(time)")
                        .font(.caption)
                }
                Spacer()
            }
        }
        .frame(width: 40,height: 20)
    }
}

struct WidgetTimes: Identifiable {
    var id: UUID
    var GTFSID: String
    var stationID: String
    var stationName: String
    var northbound: [WidgetTimes]
    var southbound: [WidgetTimes]
}

struct WidgetTime {
    var line: String
    var time: String
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationIntent
}

struct WidgetsEntryView: View {
    var entry: Provider.Entry
//    @State var widgetStyle: WidgetType = .small
//    var times = [WidgetTime(line: "A", time: "1"),WidgetTime(line: "C", time: "3"),WidgetTime(line: "E", time: "7"),WidgetTime(line: "F", time: "2")]
    
    var body: some View {
        if #available(iOSApplicationExtension 17.0, *) {
            VStack {
//                Button {
//                    print("hi")
//                } label: {
//                    Text("Hiii")
//                }
                Text("Hello !")
            }
//            .containerBackground(.background, for: .widget)
        } else {
            VStack {
                Text("Hello!")
            }
        }
    }
}

struct Widgets: Widget {
    let kind: String = "Widgets"

    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: Provider()) { entry in
            WidgetsEntryView(entry: entry)
        }
        .configurationDisplayName("My Widget")
        .description("This is an example widget.")
    }
}

struct Widgets_Previews: PreviewProvider {
    static var previews: some View {
        WidgetsEntryView(entry: SimpleEntry(date: Date(), configuration: ConfigurationIntent()))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
