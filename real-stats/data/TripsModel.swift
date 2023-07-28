//
//  TripsModel.swift
//  real-stats
//
//  Created by Conrad on 5/14/23.
//

import Foundation

struct Trip: Hashable, Codable, Identifiable {
    var id: UUID {
        return UUID()
    }
    var serviceDisruptions: Disruption
    var direction: String
    var line: String
    var stations: [String: TripStation]
    var destination: String
    var delay: Int
}

struct Disruption: Hashable, Codable {
    var reroutes: [Reroute]
    var skippedStations: [String]
    var localStations: [String]
    var suspended: [[String]]
}

struct Reroute: Hashable, Codable {
    var reroutedFrom: String
    var reroutedTo: String
    var via: String
    var sudden: Bool
}

struct TripStation: Hashable, Codable, Identifiable {
    var id: Int
    var times: [Int]
    var scheduledTime: Int
    var scheduleAdherence: Int
    var isCompleted: Bool
    var inNormalStopSequence: Bool
    var suddenReroute: Bool
}
