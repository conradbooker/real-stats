//
//  ModelData.swift
//  real-stats
//
//  Created by Conrad on 3/30/23.
//

import Foundation

var complexData: [Complex] = load("stationData.json")
var busData_dictionary: [String:BusStop] = load("bus_stops.json")
var busData_array: [BusStop_Array] = load("bus_stops_array.json")
var busRouteData: [String: [String: String]] = load("bus_type.json")
var mapViewData: [MapViewType] = load("mapTypes.json")

func load<T: Decodable>(_ filename: String) -> T {
    let data: Data

    guard let file = Bundle.main.url(forResource: filename, withExtension: nil)
    else {
        fatalError("Couldn't find \(filename) in main bundle.")
    }

    do {
        data = try Data(contentsOf: file)
    } catch {
        fatalError("Couldn't load \(filename) from main bundle:\n\(error)")
    }

    do {
        let decoder = JSONDecoder()
        return try decoder.decode(T.self, from: data)
    } catch {
        fatalError("Couldn't parse \(filename) as \(T.self):\n\n\(error)")
    }
}
