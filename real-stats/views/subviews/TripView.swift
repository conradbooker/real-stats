//
//  TripView.swift
//  real-stats
//
//  Created by Conrad on 5/26/23.
//

import Foundation
import SwiftUI

extension Collection {
  func enumeratedArray() -> Array<(offset: Int, element: Self.Element)> {
    return Array(self.enumerated())
  }
}

struct TripView: View {
    var trip: String
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 0) {
                    ForEach(getTripStationKeys(stations: exampleTrips[trip]?.stations ?? [:]), id: \.self) { station in
                        TripStationView(
                            index: exampleTrips[trip]?.stations[station]?.id ?? 0,
                            line: exampleTrips[trip]?.line ?? "",
                            trip: trip,
                            ADA: 0,
                            short1: stationsDict[station]?.short1 ?? "",
                            short2: stationsDict[station]?.short2 ?? "",
                            isTransfer: stationsDict[station]?.isTransfer ?? false,
                            transferLines: stationsDict[station]?.weekdayLines ?? [""],
                            time: exampleTrips[trip]?.stations[station]?.times[0] ?? 0
                        )
                    }
                }
            }
            .navigationTitle(trip)
        }
    }
}

struct TripView_Previews: PreviewProvider {
    static var previews: some View {
        TripView(trip: "083468_G..N")
    }
}
