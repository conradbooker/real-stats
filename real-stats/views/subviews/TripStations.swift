//
//  TripStations.swift
//  real-stats
//
//  Created by Conrad on 5/14/23.
//

import SwiftUI

var exampleTrips: [String: Trip] = load("stopTimes.json")
var stationsDict: [String: TripStationEntry] = load("tripStationData.json")

func getTripStationKeys(stations: [String: TripStation], all: Bool) -> [String] {
    var arr = [String]()
    var triggered = false
    var triggered2 = false
    
    var stationBefore = ""
    var firstStation = ""

    let sortedStations = stations.sorted { $0.value.scheduledTime < $1.value.scheduledTime }
    for station in sortedStations {
        if !triggered2 {
            triggered2 = true
            firstStation = station.key
        }
        if all {
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
    let sortedStations = stations.sorted { $0.value.scheduledTime < $1.value.scheduledTime }
    
    for station in sortedStations {
        if station.value.times[0] > Int(Date().timeIntervalSince1970) {
            if Int(Date().timeIntervalSince1970) - station.value.times[0] < 20 {
                return "At \(stationsDict[station.key]?.short1 ?? "")"
            } else {
                return "Travelling to \(stationsDict[station.key]?.short1 ?? "")"
            }
        }
    }
    return "Trip is completed!"
}

func getCurrentStationClean(stations: [String: TripStation]) -> String {
    let sortedStations = stations.sorted { $0.value.scheduledTime < $1.value.scheduledTime }
    
    for station in sortedStations {
        if station.value.times[0] - Int(Date().timeIntervalSince1970) < 20 && station.value.times[0] - Int(Date().timeIntervalSince1970) > 0 {
            return station.key
        }
    }
    return ""
}

func getStationBefore(stations: [String: TripStation]) -> String {
    let sortedStations = stations.sorted { $0.value.scheduledTime < $1.value.scheduledTime }
    
    var stationBefore = ""
    
    for station in sortedStations {
        if station.value.times[0] - Int(Date().timeIntervalSince1970) > 20 {
            return stationBefore
        }
        stationBefore = station.key
    }
    return stationBefore
}

struct TripStations: View {
    var body: some View {
        NavigationView {
            VStack {
                List(Array(exampleTrips.keys), id: \.self) { tripID in
                    NavigationLink(tripID, destination: TripView(line: "W", tripID: tripID, trips: exampleTrips))
                }
            }
        }
    }
}

struct TripStations_Previews: PreviewProvider {
    static var previews: some View {
        TripStations()
    }
}
