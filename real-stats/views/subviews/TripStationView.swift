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
        return .blue
    } else if ["N","Q","R","W"].contains(line) {
        return .yellow
    } else if ["B","D","F","M"].contains(line) {
        return .orange
    } else if ["J","Z"].contains(line) {
        return .brown
    } else if ["1","2","3"].contains(line) {
        return .red
    } else if ["4","5","6","6X"].contains(line) {
        return .green
    } else if ["7","7X"].contains(line) {
        return .purple
    }else if ["G"].contains(line) {
        return .green
    } else if ["L","H","FS","S"].contains(line) {
        return .gray
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
                        .frame(width: 10, height: 35)
                        .foregroundColor(getLineColor(line: line))
                        .padding(.horizontal, 20)
                }
            } else if index == lastIndex {
                VStack {
                    Rectangle()
                        .frame(width: 10, height: 35)
                        .foregroundColor(getLineColor(line: line))
                        .padding(.horizontal, 20)
                    Spacer()
                }
            } else {
                Rectangle()
                    .frame(width: 10, height: 70)
                    .foregroundColor(getLineColor(line: line))
                    .padding(.horizontal, 20)
            }
            if isTransfer {
                Circle()
                    .strokeBorder(.black,lineWidth: 1)
                    .background(Circle().foregroundColor(.white).frame(width: 10, height: 10))
                    .frame(width: 12, height: 12)
            } else {
                Circle()
                    .strokeBorder(.white,lineWidth: 1)
                    .background(Circle().foregroundColor(.black).frame(width: 10, height: 10))
                    .frame(width: 12, height: 12)
            }
        }
    }
}

struct TripStationView: View {
    var index: Int
    var line: String
    var trip: String
    var ADA: Int
    var short1: String
    var short2: String
    var isTransfer: Bool
    var transferLines: [String]
    var body: some View {
        HStack(spacing: 0) {
            LineShape(isTransfer: isTransfer, line: line, index: index, lastIndex: Array((exampleTrips[trip]?.stations.keys)!).count - 1)
            VStack(alignment: .leading, spacing: 0) {
                Text(short1)
                    .font(.title3)
                Text(short2)
                HStack(spacing: 2.5) {
                    ForEach(transferLines, id: \.self) { bullet in
                        Image(bullet)
                            .resizable()
                            .frame(width: 20, height: 20)
                    }
                }
            }
            Spacer()
        }
        .frame(height: 70)
    }
}

struct TripStationView_Previews: PreviewProvider {
    static var previews: some View {
        TripStationView(index: 0, line: "B", trip: "066650_5..S16R", ADA: 0, short1: "59 St", short2: "Columbus Circle", isTransfer: true, transferLines: ["1","A","C","D"])
    }
}
