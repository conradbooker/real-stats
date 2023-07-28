//
//  Network.swift
//  real-stats
//
//  Created by Conrad on 4/8/23.
//

import Foundation
import SwiftUI
import Network

let defaultStationTimeData: Data = {
    let data: Data
    let filename = "608.json"

    guard let file = Bundle.main.url(forResource: filename, withExtension: nil)
    else {
        fatalError("Couldn't find \(filename) in main bundle.")
    }

    do {
        data = try Data(contentsOf: file)
    } catch {
        fatalError("Couldn't load \(filename) from main bundle:\n\(error)")
    }
    return data
}()

let defaultTripData: Data = {
    let data: Data
    let filename = "stopTimes.json"

    guard let file = Bundle.main.url(forResource: filename, withExtension: nil)
    else {
        fatalError("Couldn't find \(filename) in main bundle.")
    }

    do {
        data = try Data(contentsOf: file)
    } catch {
        fatalError("Couldn't load \(filename) from main bundle:\n\(error)")
    }
    return data
}()

final class Network: ObservableObject {
    let monitor = NWPathMonitor()
    let queue = DispatchQueue(label: "Monitor")
     
    @Published var isConnected = false
     
    init() {
        monitor.pathUpdateHandler =  { [weak self] path in
            DispatchQueue.main.async {
                self?.isConnected = path.status == .satisfied ? true : false
            }
        }
        monitor.start(queue: queue)
    }
}

func hasNetwork() -> Bool {
    @ObservedObject var monitor = Network()
    
    if monitor.isConnected {
        return true
    }
    return false
}

class apiCall {

    func getStationTimes(station: String, completion:@escaping (NewTimes) -> ()) {
        guard let url = URL(string: "https://service-bandage.herokuapp.com/stations/\(station)") else { return }
        
        URLSession.shared.dataTask(with: url) { (data, _, _) in
            let times = try? JSONDecoder().decode(NewTimes.self, from: data ?? defaultStationTimeData)
            
            DispatchQueue.main.async {
                completion(times ?? defaultStationTimes)
            }
        }
        .resume()
    }
    func getTrip(line: String, completion:@escaping ([String: Trip]) -> ()) {
        guard let url = URL(string: "https://service-bandage.herokuapp.com/trips/\(line)") else { return }
        
        URLSession.shared.dataTask(with: url) { (data, _, _) in
            let trips = try? JSONDecoder().decode([String: Trip].self, from: data ?? defaultTripData)
            
            DispatchQueue.main.async {
                completion(trips ?? exampleTrips)
            }
        }
        .resume()
    }
}

