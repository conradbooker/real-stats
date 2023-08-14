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

struct Line_ServiceDisruption_Delay: Hashable, Codable, Identifiable {
    var id: UUID {
        return UUID()
    }
    var destination: String
    var delayAmmount: Int
    var location: String
}

struct Line_ServiceDisruption_Reroutes: Hashable, Codable, Identifiable {
    var id: UUID {
        return UUID()
    }
    var reroutedFrom: String
    var reroutedTo: String
    var via: String
    var sudden: Bool
    var occurances: Int
}

struct Line_ServiceDisruption_Local: Hashable, Codable, Identifiable {
    var id: UUID {
        return UUID()
    }
    var stations: [String]
    var occurances: Int
}

struct Line_ServiceDisruption_Skipped: Hashable, Codable, Identifiable {
    var id: UUID {
        return UUID()
    }
    var stations: [String]
    var occurances: Int
}

struct Line_ServiceDisruption_Suspended: Hashable, Codable, Identifiable {
    var id: UUID {
        return UUID()
    }
    var stations: [String]
    var occurances: Int
}

struct Line_ServiceDisruptionDirection: Hashable, Codable, Identifiable {
    var id: UUID {
        return UUID()
    }
    var delays: [String: Line_ServiceDisruption_Delay]?
    var reroutes: [String: Line_ServiceDisruption_Reroutes]?
    var localStations: [String: Line_ServiceDisruption_Local]?
    var skippedStations: [String: Line_ServiceDisruption_Skipped]?
    var suspended: [String: Line_ServiceDisruption_Suspended]?
    
}

struct Line_ServiceDisruption: Hashable, Codable, Identifiable {
    var id: UUID {
        return UUID()
    }
    var northbound: Line_ServiceDisruptionDirection
    var southbound: Line_ServiceDisruptionDirection
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
