//
//  TripStations.swift
//  real-stats
//
//  Created by Conrad on 5/14/23.
//

import SwiftUI

var exampleTrips: [String: Trip] = load("stopTimes.json")
var stationsDict: [String: TripStationEntry] = load("tripStationData.json")

func getTripStationKeys(stations: [String: TripStation]) -> [String] {
    var arr = [String]()
    let sortedStations = stations.sorted { $0.value.scheduledTime < $1.value.scheduledTime }
    for station in sortedStations {
        arr.append(station.key)
    }
    return arr
}


struct TripStations: View {
    var body: some View {
        NavigationView {
            VStack {
                List(Array(exampleTrips.keys), id: \.self) { key in
                    NavigationLink(key, destination: TripView(trip: key))
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
