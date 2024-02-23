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
    let opacityAmmount = 0.5
    if time < Int(NSDate().timeIntervalSince1970) {
        if ["A","C","E","SI","JSQ_33_HOB","33_HOB"].contains(line) {
            return Color("blue").opacity(opacityAmmount)
        } else if ["N","Q","R","W","JSQ_33"].contains(line) {
            return Color("yellow").opacity(opacityAmmount)
        } else if ["B","D","F","FX","M"].contains(line) {
            return Color("orange").opacity(opacityAmmount)
        } else if ["J","Z"].contains(line) {
            return Color("brown").opacity(opacityAmmount)
        } else if ["1","2","3","NWK_WTC"].contains(line) {
            return Color("red").opacity(opacityAmmount)
        } else if ["4","5","6","6X","HOB_WTC"].contains(line) {
            return Color("green").opacity(opacityAmmount)
        } else if ["7","7X"].contains(line) {
            return Color("purple").opacity(opacityAmmount)
        }else if ["G"].contains(line) {
            return Color("lime").opacity(opacityAmmount)
        } else if ["H","FS","GS","0"].contains(line) {
            return Color("darkerGray").opacity(opacityAmmount)
        } else if ["L"].contains(line) {
            return Color("lighterGray").opacity(opacityAmmount)
        }
        else {
            return .black
        }
    } else {
        if ["A","C","E","SI","JSQ_33_HOB","33_HOB"].contains(line) {
            return Color("blue")
        } else if ["N","Q","R","W","JSQ_33"].contains(line) {
            return Color("yellow")
        } else if ["B","D","F","FX","M"].contains(line) {
            return Color("orange")
        } else if ["J","Z"].contains(line) {
            return Color("brown")
        } else if ["1","2","3","NWK_WTC"].contains(line) {
            return Color("red")
        } else if ["4","5","6","6X","HOB_WTC"].contains(line) {
            return Color("green")
        } else if ["7","7X"].contains(line) {
            return Color("purple")
        }else if ["G"].contains(line) {
            return Color("lime")
        } else if ["H","FS","S","GS"].contains(line) {
            return Color("darkerGray")
        } else if ["L"].contains(line) {
            return Color("lighterGray")
        }
        else {
            return .black
        }
    }
}

func getLineColor_Bus(line: String, time: Int) -> Color {
    let opacityAmmount = 0.5
    if time < Int(NSDate().timeIntervalSince1970) {
        if busRouteData[line]?["type"] == "express" {
            return Color("green").opacity(opacityAmmount)
        } else if busRouteData[line]?["type"] == "sbs" {
            return Color("turqoise").opacity(opacityAmmount)
        } else if busRouteData[line]?["type"] == "limited" {
            return Color("red").opacity(opacityAmmount)
        } else {
            return Color("yellow").opacity(opacityAmmount)
        }
    } else {
        if busRouteData[line]?["type"] == "express" {
            return Color("green")
        } else if busRouteData[line]?["type"] == "sbs" {
            return Color("turqoise")
        } else if busRouteData[line]?["type"] == "limited" {
            return Color("red")
        } else {
            return Color("yellow")
        }
    }
}


func getOpacity(time: Int) -> Double {
    if time < Int(NSDate().timeIntervalSince1970) {
        return 0.5
    }
    return 1
}

struct LineShape: View {
    var trip: Trip
    var station: String
    var line: String
    var counter: Int
    
    var imageSize: CGFloat = 22
    
    var body: some View {
        VStack {
            Group {
                if (stationsDict[station]?.isTransfer ?? false) {
                    ZStack {
                        Circle()
                            .foregroundColor(Color("cDarkGray"))
                            .frame(width: imageSize-1, height: imageSize-1)
                        Circle()
                            .strokeBorder(getLineColor(line: line, time: trip.stations[station]?.times[0] ?? 0),lineWidth: 3)
                            .background(Circle().foregroundColor(Color("cDarkGray")).frame(width: imageSize-0.3305, height: imageSize-0.33333333)
                                .padding(.top,-0.005))
                        .frame(width: imageSize, height: imageSize)
                    }
                } else {
                    ZStack {
                        Circle()
                            .foregroundColor(Color("cDarkGray"))
                            .frame(width: imageSize-0.3, height: imageSize-0.3)
                        Circle()
                            .strokeBorder(Color("cDarkGray"),lineWidth: 3)
                            .background(
                                Circle()
                                    .foregroundColor(getLineColor(line: line, time: trip.stations[station]?.times[0] ?? 0))
                                    .frame(width: imageSize-1, height: imageSize-1)
                            )
                        .frame(width: imageSize, height: imageSize)
                    }
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
            if time-currentTime >= 60 {
                if abs(time-currentTime-20)/60 == 1 {
                    Text("\(abs((time-currentTime)-20)/60) min")
                } else if (time-currentTime)-20 < 60 {
                    Text("\((abs(time-currentTime)%60)+40)s")
                } else {
                    Text("\(abs((time-currentTime)-20)/60) mins")
                }
            } else if (time-currentTime) < 60 && (time-currentTime) > 0 {
                if (time-currentTime) > 20 {
                    Text("\((abs(time-currentTime)%60)-20)s")
                } else if time-currentTime > 0 {
                    Text("at station")
                }
            } else {
                if (abs(time-currentTime)/60) == 1 {
                    Text("1 min ago")
                } else {
                    Text("\(abs(time-currentTime)/60) mins ago")
                }
            }
        }
    }
}

struct TripStationView: View {
    let persistentContainer = CoreDataManager.shared.persistentContainer
    var station: String
    var line: String
    var trip: Trip
    var counter: Int
    
    @State var fromFavorites = false
    @State var selectedItem: Item?
    @State var chosenStation: Int = 0

    @FetchRequest(entity: FavoriteStation.entity(), sortDescriptors: [NSSortDescriptor(key: "dateCreated", ascending: false)]) private var favoriteStations: FetchedResults<FavoriteStation>
    
    var body: some View {
        HStack(spacing: 0) {
            ZStack {
                LineShape(trip: trip, station: station, line: line, counter: counter)
                VStack {
                    if getCurrentStationClean(stations: trip.stations) == station {
                        withAnimation(.spring(response: 0.4)) {
                            TrainDot(line: line)
                                .frame(height: 30)
                        }
                        Spacer()
                    } else if getStationBefore(stations: trip.stations) == station {
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
                Button {
                    DispatchQueue.main.async {
                        for complex in complexData {
                            for stat in complex.stations {
                                if stat.GTFSID == station {
                                    selectedItem = Item(complex: complex)
                                    for favoriteStation in favoriteStations {
                                        if favoriteStation.complexID == complex.id {
                                            fromFavorites = true
                                            chosenStation = Int(favoriteStation.chosenStationNumber)
                                            break
                                        }
                                        chosenStation = 0
                                        fromFavorites = false
                                    }
                                }
                            }
                        }
                    }
                } label: {
                    VStack(alignment: .leading, spacing: 0) {
                        Text(stationsDict[station]?.short1 ?? "")
                        if (stationsDict[station]?.short2 ?? "") != "" {
                            Text(stationsDict[station]?.short2 ?? "")
                                .font(.subheadline)
                        }
                        Text("Track " + (trip.stations[station]?.track ?? "hi") ?? "hi")
                            .font(.footnote)
                        HStack(spacing: 1.5) {
                            ForEach(stationsDict[station]?.weekdayLines ?? [""], id: \.self) { bullet in
                                if bullet != trip.line {
                                    Image(bullet)
                                        .resizable()
                                        .frame(width: 16, height: 16)
                                }
                            }
                        }
                        Spacer()
                    }
                }
                .buttonStyle(CButton())

                Spacer()
                VStack(alignment: .trailing, spacing: 0) {
                    FormattedTime(time: trip.stations[station]?.times[0] ?? 0, counter: counter)
                    Text(Date(timeIntervalSince1970: TimeInterval(trip.stations[station]?.times[0] ?? 0)), style: .time)
                    if trip.stations[station]?.suddenReroute == true {
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
            .opacity(getOpacity(time: trip.stations[station]?.times[0] ?? 0))

        }
        .sheet(item: $selectedItem) { item in
            if fromFavorites {
                // chosen station = favoriteStationNumber thing
                StationView(complex: item.complex, chosenStation: chosenStation, isFavorited: true)
                    .environment(\.managedObjectContext, persistentContainer.viewContext)
                    .syncLayoutOnDissappear()
            } else {
                StationView(complex: item.complex, chosenStation: 0, isFavorited: false)
                    .environment(\.managedObjectContext, persistentContainer.viewContext)
                    .syncLayoutOnDissappear()
            }
        }
        
    }
}

struct TripStationView_Previews: PreviewProvider {
    static var previews: some View {
        let persistedContainer = CoreDataManager.shared.persistentContainer
        TripStationView(station: "R27", line: "W", trip: exampleTrip, counter: 0)
            .environment(\.managedObjectContext, persistedContainer.viewContext)
            .previewLayout(.fixed(width: 400, height: 70))
    }
}
