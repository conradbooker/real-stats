//
//  TripStationData.swift
//  real-stats
//
//  Created by Conrad on 5/26/23.
//

import Foundation

struct TripStationEntry: Hashable, Codable {
    var stationID: Int
    var complexID: Int
    var short1: String
    var short2: String
    var stationName: String
    var boro: String
    var isTransfer: Bool
    var weekdayLines: [String]
    var structure: String
    var ADA: Int
}
