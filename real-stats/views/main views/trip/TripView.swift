//
//  TripView.swift
//  real-stats
//
//  Created by Conrad on 5/26/23.
//

import Foundation
import SwiftUI

// MARK: - FUNCTIONS

var exampleTripAndStationData: TripAndStation = load("tripAndStationData.json")
var exampleTrips: [String: Trip] = load("stopTimes.json")
var exampleTrip: Trip = load("stopTime.json")
var exampleServiceAlerts: [String: Line_ServiceDisruption] = load("exampleServiceDisruptions.json")
var exampleServiceAlert: Line_ServiceDisruption = load("exampleServiceDisruption.json")
var stationsDict: [String: TripStationEntry] = load("tripStationData.json")

func getTripStationKeys(stations: [String: TripStation], all: Bool) -> [String] {
    var arr = [String]()
    var triggered = false
    var triggered2 = false
    var notAll = false
    
    var stationBefore = ""
    var firstStation = ""

    let sortedStations = stations.sorted { $0.value.times[0] < $1.value.times[0] }
    for station in sortedStations {
        if !triggered2 {
            triggered2 = true
            firstStation = station.key
            if station.value.times[0] > Int(Date().timeIntervalSince1970) {
                notAll = true
            }
        }
        if all || notAll {
            arr.append(station.key)
        } else {
            if station.value.times[0] > Int(Date().timeIntervalSince1970) {
                if !triggered && stationBefore != "" {
                    triggered = true
                    arr.append(firstStation)
                    arr.append(stationBefore)
                }
                arr.append(station.key)
            }
            stationBefore = station.key
        }
    }
    return arr
}

func getCurrentStation(stations: [String: TripStation]) -> String {
    let sortedStations = stations.sorted { $0.value.times[0] < $1.value.times[0] }
    
    for station in sortedStations {
        if station.value.times[0] > Int(Date().timeIntervalSince1970) {
            if  station.value.times[0] - Int(Date().timeIntervalSince1970) < 20 {
                return "@ \(stationsDict[station.key]?.short1 ?? "")"
            } else {
                return "→ \(stationsDict[station.key]?.short1 ?? "")"
            }
        }
    }
    return "Trip is completed!"
}

func getCurrentStationClean(stations: [String: TripStation]) -> String {
    let sortedStations = stations.sorted { $0.value.scheduledTime < $1.value.scheduledTime }
    
    for station in sortedStations {
        if station.value.times[0] - 20 - Int(Date().timeIntervalSince1970) <= 20 && station.value.times[0] - Int(Date().timeIntervalSince1970) > 0 {
            return station.key
        }
    }
    return ""
}

func getStationBefore(stations: [String: TripStation]) -> String {
    let sortedStations = stations.sorted { $0.value.scheduledTime < $1.value.scheduledTime }
    
    var stationBefore = ""
    
    for station in sortedStations {
        if station.value.times[0] - 20 - Int(Date().timeIntervalSince1970) > 20 {
            return stationBefore
        }
        stationBefore = station.key
    }
    return stationBefore
}

extension Collection {
  func enumeratedArray() -> Array<(offset: Int, element: Self.Element)> {
    return Array(self.enumerated())
  }
}

struct TripView: View {
    let persistentContainer = CoreDataManager.shared.persistentContainer
    
    @State private var counter: Int = 0
    
    var line: String
    @State var trip: Trip
    @State var tripID: String
    
    var destination: String = ""
    
    @State var stationKeys: [String] = [String]()
    @State var all: Bool = false
    
    @State var serviceSize = CGSize()
    
    var reroutedStations: [Reroute]
    var suspendedStations: [[String]]
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    init(line: String, trip: Trip, tripID: String) {
        self.line = line
        self.trip = trip
        self._tripID = State(initialValue: tripID)
        self.stationKeys = getTripStationKeys(stations: trip.stations, all: false)
        self.destination = trip.destination
        self.destination = stationsDict[destination]?.short1 ?? ""
        self.reroutedStations = trip.serviceDisruptions.reroutes 
        self.suspendedStations = trip.serviceDisruptions.suspended 
    }
    
//    ZStack {
//        RoundedRectangle(cornerRadius: 10)
//            .foregroundColor(Color("cLessDarkGray"))
//            .shadow(radius: 2)
//            .frame(width: 150,height: 82)
//        StationBox(complex: correctComplex(Int(station.complexID)))
//            .frame(width: 150,height: 82)
//    }

    
    var body: some View {
        NavigationView {
            ZStack {
                Color("cDarkGray")
                    .ignoresSafeArea()
                ScrollView {
                    // MARK: - All Line Stations
                    VStack(alignment: .leading) {
                        Spacer()
                            .frame(height: serviceSize.height + 100)
                            .onReceive(timer) { _ in
                                withAnimation(.spring(response: 0.4)) {
                                    counter += 1
                                }
                            }
                        HStack {
                            Button {
                                all.toggle()
                                withAnimation(.spring(response: 0.4)) {
                                    stationKeys = getTripStationKeys(stations: trip.stations, all: all)
                                }
                            } label: {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 10)
                                        .frame(width: 130, height: 30)
                                        .foregroundColor(Color("cLessDarkGray"))
                                        .shadow(radius: 2)
                                    if all {
                                        Text("Fewer stations")
                                    } else {
                                        Text("More stations")
                                    }
                                }
                            }
                            .padding(.horizontal)
                            // end of button
                            
                            Spacer()
                                .onAppear {
                                    withAnimation(.spring(response: 0.4)) {
                                        stationKeys = getTripStationKeys(stations: trip.stations, all: false)
                                    }
                                }
                        }
                    }
    //                        .shadow(radius: 2)
                    .buttonStyle(CButton())
                    ZStack {
                        VStack(spacing: 0) {
                            Spacer()
                                .frame(height: 20)
                            ForEach(stationKeys, id: \.self) { station in
                                HStack(spacing:0) {
                                    VStack(spacing: 0) {
//                                        change to destination here (if station == destination)
                                        if getTripStationKeys(stations: trip.stations , all: true).first == station && !all {
                                            Rectangle()
                                                .frame(width: 16, height: 10)
                                                .foregroundColor(getLineColor(line: line, time: trip.stations[station]?.times[0] ?? 0))
                                                .padding(.horizontal,18)
                                            Rectangle()
                                                .frame(width: 16, height: 5)
                                                .foregroundColor(getLineColor(line: line, time: trip.stations[station]?.times[0] ?? 0))
                                                .padding(.horizontal,18)
                                                .opacity(0)

                                            Rectangle()
                                                .frame(width: 16, height: 5)
                                                .foregroundColor(getLineColor(line: line, time: trip.stations[station]?.times[0] ?? 0))
                                                .padding(.horizontal,18)
                                            Rectangle()
                                                .frame(width: 16, height: 5)
                                                .foregroundColor(getLineColor(line: line, time: trip.stations[station]?.times[0] ?? 0))
                                                .padding(.horizontal,18)
                                                .opacity(0)

                                            Rectangle()
                                                .frame(width: 16, height: 5)
                                                .foregroundColor(getLineColor(line: line, time: trip.stations[station]?.times[0] ?? 0))
                                                .padding(.horizontal,18)
                                            Rectangle()
                                                .frame(width: 16, height: 5)
                                                .foregroundColor(getLineColor(line: line, time: trip.stations[station]?.times[0] ?? 0))
                                                .padding(.horizontal,18)
                                                .opacity(0)

                                            Rectangle()
                                                .frame(width: 16, height: 5)
                                                .foregroundColor(getLineColor(line: line, time: trip.stations[station]?.times[0] ?? 0))
                                                .padding(.horizontal,18)

                                            Rectangle()
                                                .frame(width: 16, height: 25)
                                                .foregroundColor(getLineColor(line: line, time: trip.stations[station]?.times[0] ?? 0))
                                                .padding(.horizontal,18)
                                        } else if getTripStationKeys(stations: trip.stations , all: true).last == station {
                                            
                                        } else {
                                            Rectangle()
                                                .frame(width: 16, height: 70)
                                                .foregroundColor(getLineColor(line: line, time: trip.stations[station]?.times[0] ?? 0))
                                                .padding(.horizontal,18)
                                        }
//                                        if Int(trip.stations[station]?.id ?? 0)+1 != Int(trip.stations.count ?? 0) {
//                                            if trip.stations[station]?.id ?? 0 == 0 && !all {
//                                                Rectangle()
//                                                    .frame(width: 16, height: 10)
//                                                    .foregroundColor(getLineColor(line: line, time: trip.stations[station]?.times[0] ?? 0))
//                                                    .padding(.horizontal,18)
//                                                Rectangle()
//                                                    .frame(width: 16, height: 5)
//                                                    .foregroundColor(getLineColor(line: line, time: trip.stations[station]?.times[0] ?? 0))
//                                                    .padding(.horizontal,18)
//                                                    .opacity(0)
//
//                                                Rectangle()
//                                                    .frame(width: 16, height: 5)
//                                                    .foregroundColor(getLineColor(line: line, time: trip.stations[station]?.times[0] ?? 0))
//                                                    .padding(.horizontal,18)
//                                                Rectangle()
//                                                    .frame(width: 16, height: 5)
//                                                    .foregroundColor(getLineColor(line: line, time: trip.stations[station]?.times[0] ?? 0))
//                                                    .padding(.horizontal,18)
//                                                    .opacity(0)
//
//                                                Rectangle()
//                                                    .frame(width: 16, height: 5)
//                                                    .foregroundColor(getLineColor(line: line, time: trip.stations[station]?.times[0] ?? 0))
//                                                    .padding(.horizontal,18)
//                                                Rectangle()
//                                                    .frame(width: 16, height: 5)
//                                                    .foregroundColor(getLineColor(line: line, time: trip.stations[station]?.times[0] ?? 0))
//                                                    .padding(.horizontal,18)
//                                                    .opacity(0)
//
//                                                Rectangle()
//                                                    .frame(width: 16, height: 5)
//                                                    .foregroundColor(getLineColor(line: line, time: trip.stations[station]?.times[0] ?? 0))
//                                                    .padding(.horizontal,18)
//
//                                                Rectangle()
//                                                    .frame(width: 16, height: 25)
//                                                    .foregroundColor(getLineColor(line: line, time: trip.stations[station]?.times[0] ?? 0))
//                                                    .padding(.horizontal,18)
//                                            } else {
//                                                Rectangle()
//                                                    .frame(width: 16, height: 70)
//                                                    .foregroundColor(getLineColor(line: line, time: trip.stations[station]?.times[0] ?? 0))
//                                                    .padding(.horizontal,18)
//                                            }
//                                        }
                                    }
//                                    Text("first: \(Int(trip.stations[station]?.id ?? 0)), second: \(trip.stations.count ?? 0)")
                                    Spacer()
                                }
                            }
                            Spacer()
                        }
                        VStack(spacing: 0) {
                            ForEach(stationKeys, id: \.self) { station in
                                TripStationView(
                                    station: station, line: line, trip: trip, counter: counter
                                )
                                .environment(\.managedObjectContext, persistentContainer.viewContext)
                                .frame(height: 70)
                                
                            }
                        }
                    }
                }
                .refreshable {
                    counter += 1
                }
                // MARK: - Service disruptions + line overview
                ZStack {
                    VStack {
                        Rectangle()
                            .frame(height: serviceSize.height + 87)
                            .foregroundColor(Color("cDarkGray"))
                            .shadow(radius: 2)
                        Spacer()
                    }
                    // MARK: - Line portion stuff
                    VStack(spacing: 0) {
                        Capsule()
                            .fill(Color("second"))
                            .frame(width: 34, height: 4.5)
                            .padding(.top, -10)

                        HStack {
                            Image(line)
                                .resizable()
                                .frame(width: 30, height: 30)
                                .shadow(radius: 2)
                            Text("to \(destination)")
                                .font(.title)
                                .fontWeight(.bold)
                            Spacer()
                            Button {
                                apiCall().getIndividualTrip(trip: tripID) { (trip) in
                                    withAnimation(.spring(response: 0.4)) {
                                        self.trip = trip
                                    }
                                }
                            } label: {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 10)
                                        .frame(width: 30, height: 30)
                                        .foregroundColor(Color("cLessDarkGray"))
                                        .shadow(radius: 2)
                                    Image(systemName: "arrow.clockwise")
                                }
                            }
                            .buttonStyle(CButton())
                        }
                        // MARK: - Delay
                        if trip.delay < 60 {
                            HStack {
                                Text(getCurrentStation(stations: trip.stations ))
                                    .font(.subheadline)
                                Spacer()
                            }
                            .padding(.vertical, 2)
                        } else {
                            HStack {
                                Text("Delayed \(getCurrentStation(stations: trip.stations)) for \(trip.delay) seconds")
                                    .font(.subheadline)
                                Spacer()
                            }
                            .padding(.vertical, 2)
                        }
                        Spacer().frame(height: 5)
                        // MARK: - Disruptions
                        ScrollView(.horizontal) {
                            HStack {
                                Spacer()
                                    .frame(width: 15)
                                if trip.serviceDisruptions.reroutes != [] {
                                    ForEach(reroutedStations, id: \.self) { reroute in
                                        ZStack {
                                            if reroute.sudden == true {
                                                RoundedRectangle(cornerRadius: 10)
                                                    .stroke(.yellow,lineWidth: 3)
                                                    .foregroundColor(Color("cLessDarkGray"))
                                                    .frame(width: 130,height: 74)
                                                    .shadow(radius: 2)
                                            } else {
                                                RoundedRectangle(cornerRadius: 10)
                                                    .foregroundColor(Color("cLessDarkGray"))
                                                    .frame(width: 130,height: 74)
                                                    .shadow(radius: 2)
                                            }
                                            DisruptionBox(type: .rerouted, trip: trip, reroute: reroute, suspended: ["",""])
                                                .frame(width: 130,height: 74)
                                                .font(.subheadline)

                                        }
                                        .frame(width: 136,height: 80)
                                    }
                                }
                                if trip.serviceDisruptions.suspended != [] {
                                    ForEach(suspendedStations, id: \.self) { suspendedStationGroup in
                                        if suspendedStationGroup != [] {
                                            ZStack {
                                                RoundedRectangle(cornerRadius: 10)
                                                    .foregroundColor(Color("cLessDarkGray"))
                                                    .frame(width: 130,height: 74)
                                                    .shadow(radius: 2)
                                                DisruptionBox(type: .suspended, trip: trip, reroute: (exampleTrips["052900_W..S"]?.serviceDisruptions.reroutes[0])!, suspended: suspendedStationGroup)
                                                    .frame(width: 130,height: 74)
                                                    .font(.subheadline)
                                                
                                            }
                                            .frame(width: 136,height: 80)
                                        }
                                    }
                                }
                                if trip.serviceDisruptions.localStations.count > 0 {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 10)
                                            .foregroundColor(Color("cLessDarkGray"))
                                            .frame(width: 130,height: 74)
                                            .shadow(radius: 2)
                                        DisruptionBox(type: .local, trip: trip, reroute: (exampleTrips["052900_W..S"]?.serviceDisruptions.reroutes[0])!, suspended: ["",""])
                                            .frame(width: 130,height: 74)
                                            .font(.subheadline)
                                        
                                    }
                                    .frame(width: 136,height: 80)
                                }
                                if trip.serviceDisruptions.skippedStations.count > 0 {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 10)
                                            .foregroundColor(Color("cLessDarkGray"))
                                            .frame(width: 130,height: 74)
                                            .shadow(radius: 2)
                                        DisruptionBox(type: .skipped, trip: trip, reroute: (exampleTrips["052900_W..S"]?.serviceDisruptions.reroutes[0])!, suspended: ["",""])
                                            .frame(width: 130,height: 74)
                                            .font(.subheadline)
                                        
                                    }
                                    .frame(width: 136,height: 80)
                                }

                            }
                        }
                        .padding(.horizontal,-15)
                        .readSize { size in
                            serviceSize = size
                        }
                        Spacer()
                    }
                    .padding()
                }
            }
        }
    }
}

struct TripView_Previews: PreviewProvider {
    static var previews: some View {
        TripView(line: "W", trip: exampleTrip, tripID: "")
    }
}
