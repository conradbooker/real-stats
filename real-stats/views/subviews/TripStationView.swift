//
//  TripStation.swift
//  real-stats
//
//  Created by Conrad on 5/26/23.
//

import SwiftUI

extension Shape {
    /// fills and strokes a shape
    public func fill<S:ShapeStyle>(
        _ fillContent: S,
        stroke       : StrokeStyle
    ) -> some View {
        ZStack {
            self.fill(fillContent)
            self.stroke(style:stroke)
        }
    }
}

func getLineColor(line: String) -> Color {
    if ["A","C","E"].contains(line) {
        return Color("blue")
    } else if ["N","Q","R","W"].contains(line) {
        return Color("yellow")
    } else if ["B","D","F","M"].contains(line) {
        return Color("orange")
    } else if ["J","Z"].contains(line) {
        return Color("brown")
    } else if ["1","2","3"].contains(line) {
        return Color("red")
    } else if ["4","5","6","6X"].contains(line) {
        return Color("green")
    } else if ["7","7X"].contains(line) {
        return Color("purple")
    }else if ["G"].contains(line) {
        return Color("lime")
    } else if ["H","FS","S"].contains(line) {
        return Color("darkerGray")
    } else if ["L"].contains(line) {
        return Color("lighterGray")
    }
    else {
        return .black
    }
}

struct LineShape: View {
    var isTransfer: Bool
    var line: String
    var index: Int
    var lastIndex: Int
    var body: some View {
        ZStack {
            if index == 0 {
                VStack {
                    Spacer()
                    Rectangle()
                        .frame(width: 16, height: 60)
                        .foregroundColor(getLineColor(line: line))
                }
            } else if index == lastIndex {
                VStack {
                    Rectangle()
                        .frame(width: 16, height: 5)
                        .foregroundColor(getLineColor(line: line))
                    Spacer()
                }
            } else {
                Rectangle()
                    .frame(width: 16, height: 70)
                    .foregroundColor(getLineColor(line: line))
            }
            VStack {
                Group {
                    if isTransfer {
                        ZStack {
                            Circle()
                                .strokeBorder(.black,lineWidth: 1)
                                .background(Circle().foregroundColor(.white).frame(width: 18, height: 18))
                                .frame(width: 18, height: 18)
                            Text(line)
                                .font(.footnote)
                                .foregroundColor(.black)
                        }
                        .frame(width: 18, height: 18)
                    } else {
                        ZStack {
                            Circle()
                                .foregroundColor(.black)
                            Text(line)
                                .font(.footnote)
                                .foregroundColor(.white)
                                
                        }
                        .frame(width: 18, height: 18)
                    }
                }
                .padding(.vertical,1)
                Spacer()
            }
            .padding(.horizontal, 10)
        }
    }
}

struct FormattedTime: View {
    var time: Int
    var currentTime: Int = Int(Date().timeIntervalSince1970)
    var body: some View {
        if (time-currentTime)/60 > 1 {
            Text("\(abs(time-currentTime)/60) mins")
        } else if (time-currentTime)/60 < 1 && (time-currentTime)/60 > 0 {
            Text("<1 min")
        } else {
            Text("Departed")
        }
    }
}
//func getLocation(time: Int) -> String {
//    var currentTime: Int = Int(Date().timeIntervalSince1970)
//    if (time-currentTime)/60 > 1 {
//        return String("\(abs(time-currentTime)/60) mins")
//    } else if (time-currentTime)/60 < 1 && (time-currentTime)/60 > 0 {
//        return String("<1 min")
//    } else {
//        return String("departed")
//    }
//}

struct TripStationView: View {
    var index: Int
    var line: String
    var trip: String
    var ADA: Int
    var short1: String
    var short2: String
    var isTransfer: Bool
    var transferLines: [String]
    var time: Int
    var body: some View {
        HStack(spacing: 0) {
            LineShape(isTransfer: isTransfer, line: line, index: index, lastIndex: Array((exampleTrips[trip]?.stations.keys) ?? [:].keys).count - 1)
            VStack(alignment: .leading, spacing: 0) {
                Text(short1)
                    .font(.title3)
                if short2 != "" {
                    Text(short2)
                }
                HStack(spacing: 2.5) {
                    ForEach(transferLines, id: \.self) { bullet in
                        if bullet != exampleTrips[trip]?.line {
                            Image(bullet)
                                .resizable()
                                .frame(width: 20, height: 20)
                        }
                    }
                }
                Spacer()
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 0) {
                FormattedTime(time: time)
                    .font(.title3)
                Text(Date(timeIntervalSince1970: TimeInterval(time)), style: .time)
            }
            .padding(.trailing)
        }
        .frame(height: 70)
    }
}

struct TripStationView_Previews: PreviewProvider {
    static var previews: some View {
        TripStationView(index: 0, line: "B", trip: "066650_5..S16R", ADA: 0, short1: "59 St", short2: "Columbus Circle", isTransfer: true, transferLines: ["1","A","C","D"], time: 1601020423)
            .previewLayout(.fixed(width: 400, height: 70))
    }
}
