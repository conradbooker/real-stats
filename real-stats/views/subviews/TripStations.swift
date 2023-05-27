//
//  TripStations.swift
//  real-stats
//
//  Created by Conrad on 5/14/23.
//

import SwiftUI

var exampleTrips: [String: Trip] = load("stopTimes.json")
var TripStationsDict: [String: TripStationEntry] = load("tripStationData.json") // do the ordered dict stuff here

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
