//
//  WidgetTester.swift
//  real-stats
//
//  Created by Conrad on 4/5/23.
//

import SwiftUI
import WrappingHStack

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

struct WidgetTime {
    var line: String
    var time: String
}

struct WidgetTester: View {
    @State var widgetStyle: WidgetType = .small
    var complex: Complex
    var times = [WidgetTime(line: "A", time: "1"),WidgetTime(line: "C", time: "3"),WidgetTime(line: "E", time: "7"),WidgetTime(line: "F", time: "2")]
    
    var body: some View {
        switch widgetStyle {
        case .small:
            VStack(alignment: .leading,spacing: 0) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .frame(height: 20)
                        .foregroundColor(Color("cLessDarkGray"))
                        .shadow(radius: 2)
                    Text(complex.stations[0].short1)
                }
                .padding([.top, .leading, .trailing], 6.0)
                Text(complex.stations[0].northDir)
                    .font(.caption)
                    .padding(.leading, 6)
                
                WrappingHStack(times, id: \.self, alignment: .leading,spacing: .constant(2)) { time in
                    WidgetSmallTime(line: time.line, time: time.time)
                        .padding(.top,2)
                }
                .padding(.leading, 6)
                                
                Text(complex.stations[0].short1)
                    .font(.caption)
                    .padding(.leading, 6)
                
                WrappingHStack(times, id: \.self, alignment: .leading,spacing: .constant(2)) { time in
                    WidgetSmallTime(line: time.line, time: time.time)
                        .padding(.top,2)
                }
                .padding(.leading, 6)

                
                Spacer()
            }
        case .medium:
            VStack {
                
            }
        case .large:
            VStack {
                
            }
        }
        Text("Hello, World!")
    }
}

struct WidgetTester_Previews: PreviewProvider {
    static var previews: some View {
        WidgetTester(complex: complexData[90])
            .previewLayout(.fixed(width: 150, height: 150))
    }
}
