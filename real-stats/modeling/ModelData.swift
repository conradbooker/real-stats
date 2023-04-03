//
//  ModelData.swift
//  real-stats
//
//  Created by Conrad on 3/30/23.
//

import Foundation

var complexData: [Complex] = load("stationData.json")

func load<T: Decodable>(_ filename: String) -> T {
    print("hello")
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
