//
//  Network.swift
//  real-stats
//
//  Created by Conrad on 4/8/23.
//

import Foundation
import SwiftUI
import Network

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
        guard let url = URL(string: "http://127.0.0.1:5000/stations/\(station)") else { return }
        
        URLSession.shared.dataTask(with: url) { (data, _, _) in
            let times = try! JSONDecoder().decode(NewTimes.self, from: data!)
            
            DispatchQueue.main.async {
                completion(times)
            }
        }
        .resume()
    }
    func getTrip(line: String, completion:@escaping ([String: Trip]) -> ()) {
        guard let url = URL(string: "http://127.0.0.1:5000/trips/\(line)") else { return }
        
        URLSession.shared.dataTask(with: url) { (data, _, _) in
            let trips = try! JSONDecoder().decode([String: Trip].self, from: data!)
            
            DispatchQueue.main.async {
                completion(trips)
            }
        }
        .resume()
    }
}

