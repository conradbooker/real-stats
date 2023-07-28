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

func getLineColor(line: String, time: Int) -> Color {
    if time < Int(NSDate().timeIntervalSince1970) {
        return .gray
    } else if ["A","C","E"].contains(line) {
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

func getOpacity(time: Int) -> Double {
    if time < Int(NSDate().timeIntervalSince1970) {
        return 0.5
    }
    return 1
}

struct LineShape: View {
    var trips: [String: Trip]
    var tripID: String
    var station: String
    var line: String
    var counter: Int
    
    var imageSize: CGFloat = 22
    
    var body: some View {
        VStack {
            Group {
                if stationsDict[station]?.isTransfer ?? false {
                    Circle()
                        .strokeBorder(getLineColor(line: line, time: trips[tripID]?.stations[station]?.times[0] ?? 0),lineWidth: 3)
                        .background(Circle().foregroundColor(Color("cDarkGray")).frame(width: imageSize-1, height: imageSize-1))
                        .frame(width: imageSize, height: imageSize)
                } else {
                    Circle()
                        .strokeBorder(Color("cDarkGray"),lineWidth: 3)
                        .background(Circle().foregroundColor(getLineColor(line: line, time: trips[tripID]?.stations[station]?.times[0] ?? 0)).frame(width: imageSize-1, height: imageSize-1))
                        .frame(width: imageSize, height: imageSize)
                }
            }
            .padding(.vertical,1)
            
            Spacer()
        }
        .padding(.horizontal, 15)
    }
}

struct FormattedTime: View {
    var time: Int
    var currentTime: Int = Int(Date().timeIntervalSince1970)
    var counter: Int
    
    var body: some View {
        VStack {
//            Text("\(time-currentTime)")
            if time-currentTime > 60 {
                Text("\(abs(time-currentTime)/60) mins")
            } else if (time-currentTime) < 60 && (time-currentTime) > 0 {
                Text("<1 min")
            } else {
                Text("\(abs(time-currentTime)/60) mins ago")
            }
        }
    }
}

struct TripStationView: View {
    var tripID: String
    var station: String
    var line: String
    var trips: [String: Trip]
    var counter: Int
    
    var body: some View {
        HStack(spacing: 0) {
            ZStack {
                LineShape(trips: trips, tripID: tripID, station: station, line: line, counter: counter)
                VStack {
                    if getCurrentStationClean(stations: trips[tripID]?.stations ?? [:]) == station {
                        withAnimation(.spring(response: 0.4)) {
                            TrainDot(line: line)
                                .frame(height: 30)
                        }
                        Spacer()
                    } else if getStationBefore(stations: trips[tripID]?.stations ?? [:]) == station {
                        Spacer()
                            .frame(height: 20)
                        withAnimation(.spring(response: 0.4)) {
                            TrainDot(line: line)
                                .frame(height: 50)
                        }
                        Spacer()
                    }

                }
            }
            Group {
                VStack(alignment: .leading, spacing: 0) {
                    Text(stationsDict[station]?.short1 ?? "")
                    if (stationsDict[station]?.short2 ?? "") != "" {
                        Text(stationsDict[station]?.short2 ?? "")
                            .font(.subheadline)
                    }
                    HStack(spacing: 1.5) {
                        ForEach(stationsDict[station]?.weekdayLines ?? [""], id: \.self) { bullet in
                            if bullet != trips[tripID]?.line ?? "" {
                                Image(bullet)
                                    .resizable()
                                    .frame(width: 16, height: 16)
                            }
                        }
                    }
                    Spacer()
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 0) {
                    FormattedTime(time: trips[tripID]?.stations[station]?.times[0] ?? 0, counter: counter)
                    Text(Date(timeIntervalSince1970: TimeInterval(trips[tripID]?.stations[station]?.times[0] ?? 0)), style: .time)
                    if trips[tripID]?.stations[station]?.suddenReroute == true {
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .frame(width: 15,height: 15)
                                .foregroundStyle(.black, .yellow)
                                .shadow(radius: 2)
                            Text("Sudden reroute")
                        }
                    }
                    Spacer()
                }
                .padding(.trailing)
            }
            .opacity(getOpacity(time: trips[tripID]?.stations[station]?.times[0] ?? 0))
        }
        
    }
}

struct TripStationView_Previews: PreviewProvider {
    static var previews: some View {
        TripStationView(tripID: "104700_W..N", station: "R27", line: "W", trips: exampleTrips, counter: 0)
            .previewLayout(.fixed(width: 400, height: 70))
    }
}
