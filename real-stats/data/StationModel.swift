//
//  Station.swift
//  real-stats
//
//  Created by Conrad on 3/30/23.
//

import Foundation
import CoreLocation


/*
 {
    "id": 635,
    "complexName": "Whitehall St-South Ferry",
    "stations": [
       {
          "GTFSID": "R27",
          "stationID": 23,
          "stopName": "Whitehall St-South Ferry",
          "lines": [],
          "trunk": "Broadway",
          "borough": "M",
          "lat": 40.703087,
          "long": -74.012994,
          "northDir": "Uptown & Queens",
          "southDir": "Brooklyn",
          "ADA": 0,
          "short1": "South Ferry",
          "short2": "Whitehall St",
          "expectedLines": [
             "N",
             "R",
             "W"
          ]
       },
       {
          "GTFSID": 142,
          "stationID": 330,
          "stopName": "South Ferry",
          "lines": [],
          "trunk": "Broadway - 7Av",
          "borough": "M",
          "lat": 40.702068,
          "long": -74.013664,
          "northDir": "Uptown & The Bronx",
          "southDir": "",
          "ADA": 1,
          "short1": "South Ferry",
          "short2": "",
          "expectedLines": [
             1
          ]
       }
    ]
 }

 */

struct Complex: Hashable, Codable, Identifiable {
    var id: Int
    var complexName: String
    var searchName: String
    var stations: [Station]
    var location: CLLocation {
        CLLocation (
            latitude: stations[0].lat,
            longitude: stations[0].long
            )
    }
}

struct Station: Hashable, Codable, Identifiable {
    var GTFSID: String
    var id: Int
    
    var stopName: String
    var trunk: String
    var borough: String
    
    var lat: Double
    var long: Double
    var location: CLLocationCoordinate2D {
        CLLocationCoordinate2D(
            latitude: lat,
            longitude: long)
    }
    
    var northDir: String
    var southDir: String
    var ADA: Int
    var short1: String
    var short2: String
    var weekdayLines: [String]
}

struct BusStop: Hashable, Codable, Identifiable {
    var id: UUID {
        return UUID()
    }
    var name: String
    var short1: String
    var short2: String
//    var lines: [String]
    
    var lat: Double
    var lon: Double
    var location: CLLocation {
        CLLocation (
            latitude: CLLocationDegrees(lat),
            longitude: CLLocationDegrees(lon)
            )
    }
}

struct BusStop_Array: Hashable, Codable, Identifiable {
    var id: String
    var name: String
    var short1: String
    var short2: String
    var lines: [String]?
    
    var lat: Double
    var lon: Double
    var location: CLLocation {
        CLLocation (
            latitude: CLLocationDegrees(lat),
            longitude: CLLocationDegrees(lon)
            )
    }
}

