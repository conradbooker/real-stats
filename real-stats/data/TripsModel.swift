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
}

struct Disruption: Hashable, Codable {
    var delays: [String]
    var reroutes: [String]
}

struct TripStation: Hashable, Codable, Identifiable {
    var id: Int
    var times: [Int]
    var scheduledTime: Int
    var scheduleAdherence: Int
    var isCompleted: Bool
    var inNormalStopSequence: Bool
}
