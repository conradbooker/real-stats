//
//  StationRow.swift
//  real-stats
//
//  Created by Conrad on 4/1/23.
//

import SwiftUI

enum disruption {
    case delayed
    case none
    case skippedStations
    case slowSpeeds
    case reroutes
}

var defaultStationTimes: NewTimes = load("608.json")
var placeHolderStationTimes: NewTimes = load("601.json")

struct LineItem: Identifiable {
    var id = UUID()
    var direction: String
    var line: String
}
struct TripsItem: Identifiable {
    var id = UUID()
    var trips: [String: Trip]
    var line: String
    var tripID: String
}
struct TripItem: Identifiable {
    var id = UUID()
    var trip: Trip
    var line: String
    var tripID: String
}
struct DisruptionItem: Identifiable {
    var id = UUID()
    var line: String
    var direction: String
}

struct StationTimeRow: View {
    let persistentContainer = CoreDataManager.shared.persistentContainer
    
    var line: String
    var direction: String
    var trainTimes: NewTimes
    var times: [String]
    
    var tripID: String = ""
    @State var currentStation: String = ""
    
    @State var selectedTrip: TripItem?
    @State var selectedDisruption: DisruptionItem?
    
    @State var showTrips = false
    @State var showBottom = false

    var trips: [String: Trip]
    
    var trip1ID: String = ""
    var trip2ID: String = ""
    var trip3ID: String = ""
    var track: String = ""

    @State private var tripIDs = [String]()

    init(line: String, direction: String, trainTimes: NewTimes, times: [String], trips: [String: Trip]) {
        self.line = line
        self.trainTimes = trainTimes
        self.times = times
        self.direction = direction
        if direction == "N" {
            self.tripID = trainTimes.north?[line]??[times[0]]?.tripID ?? ""
        } else {
            self.tripID = trainTimes.south?[line]??[times[0]]?.tripID ?? ""
        }
        self.trips = trips
        self.currentStation = stationsDict[
            getCurrentStationClean(stations:trips[tripID]?.stations ?? [:])
        ]?.short1 ?? ""
        if direction == "N" {
            if times.count > 2 {
                trip3ID = trainTimes.north?[line]??[times[2]]?.tripID ?? ""
            }
            if times.count > 1 {
                trip2ID = trainTimes.north?[line]??[times[1]]?.tripID ?? ""
            }
            trip1ID = trainTimes.north?[line]??[times[0]]?.tripID ?? ""
            self.track = trainTimes.north?[line]??[times[0]]?.track ?? ""
        } else {
            if times.count > 2 {
                trip3ID = trainTimes.south?[line]??[times[2]]?.tripID ?? ""
            }
            if times.count > 1 {
                trip2ID = trainTimes.south?[line]??[times[1]]?.tripID ?? ""
            }
            trip1ID = trainTimes.south?[line]??[times[0]]?.tripID ?? ""
            self.track = trainTimes.south?[line]??[times[0]]?.track ?? ""
        }

    }
    
    
    var body: some View {
        ZStack {
            GeometryReader { geometry in
                ZStack {
                    HStack(spacing: 0) {
                        Spacer()
                        // MARK: - Third Time
                        Button {
                            DispatchQueue.main.async {
                                if times.count > 2 {
                                    showTrips = true
                                    if direction == "N" {
                                        selectedTrip = TripItem(trip: trips[trip3ID]!, line: line, tripID: trainTimes.north?[line]??[times[2]]?.tripID ?? "")
                                    } else {
                                        selectedTrip = TripItem(trip: trips[trip3ID]!, line: line, tripID: trainTimes.south?[line]??[times[2]]?.tripID ?? "")
                                    }
                                }
                            }
                        } label: {
                            ZStack {
                                RoundedRectangle(cornerRadius: 15)
                                    .foregroundColor(bgColor.second.value)
                                    .shadow(radius: 2)
                                HStack(spacing: 0) {
                                    Spacer()
                                    if times.count > 2 {
                                        individualTime(time: Int(times[2]) ?? 0)
                                            .padding(.trailing,10)
                                    } else {
                                        Text("--")
                                            .padding(.trailing,10)
                                    }
                                }
                            }
                            .frame(width: geometry.size.width*2.7/12, height: 55)
                        }
                        .buttonStyle(CButton())
                    }
                    // MARK: - Second Time
                    HStack(spacing: 0) {
                        Spacer()
                            .frame(width: geometry.size.width*6.3/12)
                        Button {
                            if times.count > 1 {
                                showTrips = true
                                if direction == "N" {
                                    selectedTrip = TripItem(trip: trips[trip2ID]!, line: line, tripID: trainTimes.north?[line]??[times[1]]?.tripID ?? "")
                                } else {
                                    selectedTrip = TripItem(trip: trips[trip2ID]!, line: line, tripID: trainTimes.south?[line]??[times[1]]?.tripID ?? "")
                                }
                            }
                        } label: {
                            ZStack {
                                RoundedRectangle(cornerRadius: 15)
                                    .foregroundColor(bgColor.third.value)
                                    .shadow(radius: 2)
                                HStack(spacing: 0) {
                                    Spacer()
                                    if times.count > 1 {
                                        individualTime(time: Int(times[1]) ?? 0)
                                            .padding(.trailing,10)
                                    } else {
                                        Text("--")
                                            .padding(.trailing, 10)
                                    }
                                }
                            }
                            .frame(width: geometry.size.width*2.7/12, height: 55)
                        }
                        .buttonStyle(CButton())
                    }
                    // MARK: - First Time
                    HStack(spacing: 0) {
                        Button {
                            DispatchQueue.main.async {
                                showTrips = true
                                if direction == "N" {
                                    print(trip1ID)
                                    selectedTrip = TripItem(trip: trips[trip1ID]!, line: line, tripID: trainTimes.north?[line]??[times[0]]?.tripID ?? "")
                                } else {
                                    selectedTrip = TripItem(trip: trips[trip1ID]!, line: line, tripID: trainTimes.south?[line]??[times[0]]?.tripID ?? "")
                                }
                            }
                        } label: {
                            ZStack {
                                Rectangle()
                                    .cornerRadius(15, corners: [.topRight, .bottomRight])
                                    .foregroundColor(bgColor.fourth.value)
                                    .shadow(radius: 2)
                                HStack(spacing: 0) {
                                    VStack(alignment: .leading) {
                                        Text(stationsDict[
                                            trips[trip1ID]?.destination ?? ""
                                        ]?.short1 ?? "Broad Channel")
                                        .fontWeight(.bold)
                                        if (trips[trip1ID]?.delay ?? 0 < 60) {
                                            Text(getCurrentStation(stations: trips[trip1ID]?.stations ?? [:]))
                                                .foregroundColor(Color("green"))
                                                .font(.footnote)
                                        } else {
                                            Text("Stuck \(getCurrentStation(stations: trips[trip1ID]?.stations ?? [:])) for \(trips[trip1ID]?.delay ?? 60) sec")
                                                .foregroundColor(Color("red"))
                                                .font(.footnote)
                                        }
                                        Text("Track " + track)
                                            .font(.footnote)
                                    }
                                    Spacer()
                                    individualTime(time: Int(times[0]) ?? 0)
                                        .padding(.trailing,15)
                                    //                                Text(trainTimes.south?[line]??[times[0]]?.tripID ?? "")
                                }
                                .padding(.leading,37)
                            }
                            .frame(width: geometry.size.width*8.1/12, height: 55)
                            .padding(.leading,25)
                        }
                        .buttonStyle(CButton())
                        Spacer()
                    }
                    // MARK: - Line
                    HStack(spacing: 0) {
                        Button {
                            DispatchQueue.main.async {
                                if direction == "N" {
                                    selectedDisruption = DisruptionItem(line: line, direction: "north")
                                } else {
                                    selectedDisruption = DisruptionItem(line: line, direction: "south")
                                }
                            }
                        } label: {
                            ZStack {
                                RoundedRectangle(cornerRadius: 15)
                                    .foregroundColor(bgColor.fifth.value)
                                    .shadow(radius: 2)
                                    .frame(width: 55, height: 55)
                                    .padding(.leading, -7.4)
                                HStack(spacing: 0) {
                                    ZStack {
                                        Image(line)
                                            .resizable()
                                            .frame(width: 40,height: 40)
                                            .padding(7.5)
                                            .shadow(radius: 2)
                                        if trips[trip1ID]?.serviceDisruptions.skippedStations != [] || trips[trip1ID]?.serviceDisruptions.localStations != [] || trips[trip1ID]?.serviceDisruptions.suspended != [] || trips[trip1ID]?.serviceDisruptions.reroutes != [] {
                                            VStack {
                                                Spacer()
                                                HStack {
                                                    Spacer()
                                                    Image(systemName: "exclamationmark.triangle.fill")
                                                        .frame(width: 15,height: 15)
                                                        .foregroundStyle(.black, .yellow)
                                                        .shadow(radius: 2)
                                                }
                                                Spacer()
                                                    .frame(height: 3)
                                            }
                                            .frame(width: 40,height: 40)
                                        }
                                    }
                                    Spacer()
                                    //                                Text(trainTimes.south?[line]??[times[0]]?.tripID ?? "")
                                }
                            }
                            .frame(width: geometry.size.width*2/12, height: 55)
                        }
                        .buttonStyle(CButton())
                        Spacer()
                    }
                }
            }
        }
        .sheet(item: $selectedTrip) { trip in
            TripView(line: trip.line, trip: trip.trip, tripID: trip.tripID)
                .environment(\.managedObjectContext, persistentContainer.viewContext)
                .syncLayoutOnDissappear()
        }.sheet(item: $selectedDisruption) { disruption in
            serviceAlertsView(line: disruption.line, direction: disruption.direction)
                .syncLayoutOnDissappear()
        }
    }
}

struct individualTime: View {
    var currentTime: Int = Int(NSDate().timeIntervalSince1970)
    var time: Int
    var body: some View {
        VStack {
            if time-currentTime >= 70 {
                Text("\(Int(time-currentTime-10)/60)")
                    .font(.title3)
                    .fontWeight(.bold)
                if Int(time-currentTime-10)/60 == 1 {
                    Text("min")
                        .font(.footnote)
                } else {
                    Text("mins")
                        .font(.footnote)
                }
            } else if time-currentTime > 69 {
                Text("<1")
                    .font(.title2)
                    .fontWeight(.bold)
                Text("min")
                    .font(.footnote)
            } else if time-currentTime > 20 {
                Text("due")
            } else if time-currentTime > 0 {
                Text("here")
            } else {
                Text("left")
            }
        }
    }
}

struct StationTimeRow_Previews: PreviewProvider {
    static var previews: some View {
        
        StationTimeRow(
            line: "6", direction: "N",
            trainTimes: placeHolderStationTimes,
            times: getSortedTimes(direction: placeHolderStationTimes.north!["6X"]!!), trips: exampleTrips
        )
        .previewLayout(.fixed(width: 375, height: 65))
    }
}
