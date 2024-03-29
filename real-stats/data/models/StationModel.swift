//
//  Station.swift
//  real-stats
//
//  Created by Conrad on 3/30/23.
//

import Foundation
import CoreLocation
import SwiftUI

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

struct Complex: Hashable, Codable, Identifiable, Equatable {
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

struct Station: Hashable, Codable, Identifiable, Equatable {
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
//    var mapLocation: MapLocation
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

struct MapViewType: Hashable, Codable, Identifiable {
    var id: Int
    var country: String
    var region: String
    var mapName: String
    var zoomScales: [Int]
    var mapTypes: [String]
    var stationLocations: [String: MapLocation]
}

func getMapType(_ city: String) -> String {
    let calendar = Calendar.current
    let components = calendar.dateComponents([.hour, .minute, .weekday], from: Date())
    
    guard let hour = components.hour, let minute = components.minute, let weekday = components.weekday else {
        return "weekend"
    }
    
    let time = Double(hour) + Double(minute) / 60.0

    if city == "nyc" {
        if time >= 0 && time < 5.5 { // 5.5 corresponds to 5:30 AM
            return "night"
        }
        
        if weekday >= 2 && weekday <= 6 {
            if time >= 5.5 && time < 9 {
                return "am"
            }
            
            if time >= 9 && time < 12.5 {
                return "week_am"
            }
            if time >= 12.5 && time < 15 {
                return "week_pm"
            }
            if time >= 15 && time < 20 {
                return "pm"
            } else {
                return "weekend"
            }
        }        
        return "weekend"
    }
    return "default"
}

struct MapLocation: Hashable, Codable {
    var x: Double
    var y: Double
//    var position: CGPoint {
//
//        return CGPoint(x: self.x, y: self.y)
//    }
    var station: Int
    var shape: Int
    var angle: Int
    var angle_deg: Angle {
        return Angle(degrees: Double(self.angle * 45))
    }
}
