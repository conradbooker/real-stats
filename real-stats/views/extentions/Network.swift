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

let defaultTripsData: Data = {
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
let defaultTripData: Data = {
    let data: Data
    let filename = "stopTime.json"

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
let defaultTripAndStationData: Data = {
    let data: Data
    let filename = "tripAndStationData.json"

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

struct TripAndStation: Hashable, Codable {
    var trips: [String: Trip]
    var station: NewTimes
}

class apiCall {
    func getStationTimes(station: String, completion:@escaping (NewTimes) -> ()) {
        guard let url = URL(string: "https://service-bandage.herokuapp.com/stations/\(station)?APIKey=\(getApiKey())") else { return }
        
        URLSession.shared.dataTask(with: url) { (data, _, _) in
            let times = try? JSONDecoder().decode(NewTimes.self, from: data ?? defaultStationTimeData)
            
            completion(times ?? defaultStationTimes)
        }
        .resume()
    }
    func getTrip(line: String, completion:@escaping ([String: Trip]) -> ()) {
        guard let url = URL(string: "https://service-bandage.herokuapp.com/trips/\(line)?APIKey=\(getApiKey())") else { return }
        
        URLSession.shared.dataTask(with: url) { (data, _, _) in
            let trips = try? JSONDecoder().decode([String: Trip].self, from: data ?? defaultTripsData)
            
            completion(trips ?? exampleTrips)
        }
        .resume()
    }
    func getIndividualTrip(trip: String, completion:@escaping (Trip) -> ()) {
        guard let url = URL(string: "https://service-bandage.herokuapp.com/individual-trip/\(trip)?APIKey=\(getApiKey())") else { return }
        print(trip)
        
        URLSession.shared.dataTask(with: url) { (data, _, _) in
            let trips = try? JSONDecoder().decode(Trip.self, from: data ?? defaultTripData)
            
            completion(trips ?? exampleTrip)
        }
        .resume()
    }
    
    func getStationAndTrips(station: String, completion: @escaping (TripAndStation) -> ()) {
        guard let url = URL(string: "https://service-bandage.herokuapp.com/stations-with-trips/\(station)?APIKey=\(getApiKey())") else { return }
                
        URLSession.shared.dataTask(with: url) { (data, _, _) in
            let tripAndStation = try? JSONDecoder().decode(TripAndStation.self, from: data ?? defaultTripAndStationData)
            
            DispatchQueue.main.async {
                completion(tripAndStation ?? exampleTripAndStationData)
            }
        }
        .resume()
    }
    
    func getMultipleTrips(trips: [String], completion:@escaping ([String: Trip]) -> ()) {
        guard let url = URL(string: "https://service-bandage.herokuapp.com/multiple-trips?APIKey=\(getApiKey())") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let parameters: [String: Any] = [
            "trips": trips
        ]
        request.httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: .fragmentsAllowed)
        
        print(parameters)

        URLSession.shared.dataTask(with: request) { (data, _, _) in
            let trips = try? JSONDecoder().decode([String: Trip].self, from: data ?? defaultTripsData)
            
            completion(trips ?? exampleTrips)
        }
        .resume()
    }
    func getAllServiceDisruptions(line: String, completion:@escaping ([String: Line_ServiceDisruption]) -> ()) {
        guard let url = URL(string: "https://service-bandage.herokuapp.com/service-alerts/\(line)?APIKey=\(getApiKey())") else { return }
        
        URLSession.shared.dataTask(with: url) { (data, _, _) in
            let trips = try? JSONDecoder().decode([String: Line_ServiceDisruption].self, from: data ?? defaultTripsData)
            
            completion(trips ?? exampleServiceAlerts)
        }
        .resume()
    }
    func getServiceDisruption(line: String, completion: @escaping (Line_ServiceDisruption) -> ()) {
        guard let url = URL(string: "https://service-bandage.herokuapp.com/service-alerts/\(line)?APIKey=\(getApiKey())") else { return }
        
        URLSession.shared.dataTask(with: url) { (data, _, _) in
            let trips = try? JSONDecoder().decode(Line_ServiceDisruption.self, from: data ?? defaultTripsData)
            
            completion(trips ?? exampleServiceAlert)
        }
        .resume()
    }
}




class apiCallProduction {
    func getStationTimes(station: String, completion:@escaping (NewTimes) -> ()) {
        guard let url = URL(string: "https://service-bandage.herokuapp.com/stations/\(station)?APIKey=\(getApiKey())") else { return }
        
        URLSession.shared.dataTask(with: url) { (data, _, _) in
            let times = try? JSONDecoder().decode(NewTimes.self, from: data ?? defaultStationTimeData)
            
            DispatchQueue.main.async {
                completion(times ?? defaultStationTimes)
            }
        }
        .resume()
    }
    func getTrip(line: String, completion:@escaping ([String: Trip]) -> ()) {
        guard let url = URL(string: "https://service-bandage.herokuapp.com/trips/\(line)?APIKey=\(getApiKey())") else { return }
        
        URLSession.shared.dataTask(with: url) { (data, _, _) in
            let trips = try? JSONDecoder().decode([String: Trip].self, from: data ?? defaultTripsData)
            
            DispatchQueue.main.async {
                completion(trips ?? exampleTrips)
            }
        }
        .resume()
    }
    func getIndividualTrip(trip: String, completion:@escaping (Trip) -> ()) {
        guard let url = URL(string: "https://service-bandage.herokuapp.com/individual-trip/\(trip)?APIKey=\(getApiKey())") else { return }
        
        URLSession.shared.dataTask(with: url) { (data, _, _) in
            let trips = try? JSONDecoder().decode(Trip.self, from: data ?? defaultTripData)
            
            DispatchQueue.main.async {
                completion(trips ?? exampleTrip)
            }
        }
        .resume()
    }
    func getMultipleTrips(trips: [String], completion:@escaping ([String: Trip]) -> ()) {
        guard let url = URL(string: "https://service-bandage.herokuapp.com/multiple-trips?APIKey=\(getApiKey())") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let jsonData: Data
        do {
            let parameters: [String: [String]] = [
                "trips": trips
            ]
            jsonData = try JSONSerialization.data(withJSONObject: parameters)
        } catch {
            return
        }

        request.httpBody = jsonData

        URLSession.shared.dataTask(with: url) { (data, _, _) in
            let trips = try? JSONDecoder().decode([String: Trip].self, from: data ?? defaultTripsData)
            
            DispatchQueue.main.async {
                completion(trips ?? exampleTrips)
            }
        }
        .resume()
    }
    
    func getAllServiceDisruptions(line: String, completion:@escaping ([String: Line_ServiceDisruption]) -> ()) {
        guard let url = URL(string: "https://service-bandage.herokuapp.com/service-alerts/\(line)?APIKey=\(getApiKey())") else { return }
        
        URLSession.shared.dataTask(with: url) { (data, _, _) in
            let trips = try? JSONDecoder().decode([String: Line_ServiceDisruption].self, from: data ?? defaultTripsData)
            
            DispatchQueue.main.async {
                completion(trips ?? exampleServiceAlerts)
            }
        }
        .resume()
    }
    func getServiceDisruption(line: String, completion:@escaping (Line_ServiceDisruption) -> ()) {
        guard let url = URL(string: "https://service-bandage.herokuapp.com/service-alerts/\(line)?APIKey=\(getApiKey())") else { return }
        
        URLSession.shared.dataTask(with: url) { (data, _, _) in
            let trips = try? JSONDecoder().decode(Line_ServiceDisruption.self, from: data ?? defaultTripsData)
            
            DispatchQueue.main.async {
                completion(trips ?? exampleServiceAlert)
            }
        }
        .resume()
    }
}

