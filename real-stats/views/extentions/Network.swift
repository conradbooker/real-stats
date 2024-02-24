//
//  Network.swift
//  real-stats
//
//  Created by Conrad on 4/8/23.
//

import Foundation
import SwiftUI
import Network

enum urls {
    case local
    case production
    
    var value: String {
        switch self {
        case .local:
            return "http://127.0.0.1:5000/"
        case .production:
            return "https://service-bandage.herokuapp.com/"
        }
    }

}


var base_url: String = urls.production.value


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

let defaultTripsData_bus: Data = {
    let data: Data
    let filename = "busStopTimes.json"

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
let defaultTrip_bus: Data = {
    let data: Data
    let filename = "defaultBusTrip.json"

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
let defaultTripData_bus: Data = {
    let data: Data
    let filename = "busStopTime.json"

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

class bus_API_Call {
    func getMultipleStops(stop_ids: [String], completion:@escaping ([String: Bus_Times]) -> ()) {
        guard let url = URL(string: "\(base_url)usa/nyc/bus/multiple-stops-with-trips?APIKey=\(getApiKey())") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let parameters: [String: Any] = [
            "stop_ids": stop_ids
        ]
        request.httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: .fragmentsAllowed)
        
//        print(parameters)

        URLSession.shared.dataTask(with: request) { (data, _, _) in
            let stops = try? JSONDecoder().decode([String: Bus_Times].self, from: data ?? defaultTripsData_bus)
            
            completion(stops ?? defaultBusTimes_dict)
        }
        .resume()
    }
    func getIndividualTrip(trip: String, completion: @escaping (BusTrip) -> ()) {
        guard let url = URL(string: "\(base_url)usa/nyc/bus/individual-trip/\(trip)?APIKey=\(getApiKey())") else { return }
        print(trip)
        
        URLSession.shared.dataTask(with: url) { (data, _, _) in
            let trips = try? JSONDecoder().decode(BusTrip.self, from: data ?? defaultTripData)
            
            completion(trips ?? defaultBusTrip)
        }
        .resume()
    }
}

class apiCall {
    func getStationTimes(station: String, completion:@escaping (NewTimes) -> ()) {
        guard let url = URL(string: "\(base_url)stations/\(station)?APIKey=\(getApiKey())") else { return }
        
        URLSession.shared.dataTask(with: url) { (data, _, _) in
            let times = try? JSONDecoder().decode(NewTimes.self, from: data ?? defaultStationTimeData)
            
            completion(times ?? defaultStationTimes)
        }
        .resume()
    }
    func getTrip(line: String, completion:@escaping ([String: Trip]) -> ()) {
        guard let url = URL(string: "\(base_url)trips/\(line)?APIKey=\(getApiKey())") else { return }
        
        URLSession.shared.dataTask(with: url) { (data, _, _) in
            let trips = try? JSONDecoder().decode([String: Trip].self, from: data ?? defaultTripsData)
            
            completion(trips ?? exampleTrips)
        }
        .resume()
    }
    func getIndividualTrip(trip: String, completion:@escaping (Trip) -> ()) {
        guard let url = URL(string: "\(base_url)individual-trip/\(trip)?APIKey=\(getApiKey())") else { return }
        print(trip)
        
        URLSession.shared.dataTask(with: url) { (data, _, _) in
            let trips = try? JSONDecoder().decode(Trip.self, from: data ?? defaultTripData)
            
            completion(trips ?? exampleTrip)
        }
        .resume()
    }
    
    func getStationAndTrips(station: String, completion: @escaping (TripAndStation) -> ()) {
        guard let url = URL(string: "\(base_url)stations-with-trips/\(station)?APIKey=\(getApiKey())") else { return }
                
        URLSession.shared.dataTask(with: url) { (data, _, _) in
            let tripAndStation = try? JSONDecoder().decode(TripAndStation.self, from: data ?? defaultTripAndStationData)
            
            DispatchQueue.main.async {
                completion(tripAndStation ?? exampleTripAndStationData)
            }
        }
        .resume()
    }
    
    func getMultipleTrips(trips: [String], completion:@escaping ([String: Trip]) -> ()) {
        guard let url = URL(string: "\(base_url)multiple-trips?APIKey=\(getApiKey())") else { return }
        
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
        guard let url = URL(string: "\(base_url)service-alerts/\(line)?APIKey=\(getApiKey())") else { return }
        
        URLSession.shared.dataTask(with: url) { (data, _, _) in
            let trips = try? JSONDecoder().decode([String: Line_ServiceDisruption].self, from: data ?? defaultTripsData)
            
            completion(trips ?? exampleServiceAlerts)
        }
        .resume()
    }
    func getServiceDisruption(line: String, completion: @escaping (Line_ServiceDisruption) -> ()) {
        guard let url = URL(string: "\(base_url)service-alerts/\(line)?APIKey=\(getApiKey())") else { return }
        
        URLSession.shared.dataTask(with: url) { (data, _, _) in
            let trips = try? JSONDecoder().decode(Line_ServiceDisruption.self, from: data ?? defaultTripsData)
            
            completion(trips ?? exampleServiceAlert)
        }
        .resume()
    }
    
    func getCurrentVersion(completion: @escaping (Bool) -> ()) {
        guard let bundleId = Bundle.main.infoDictionary?["CFBundleIdentifier"] as? String else { return }
        guard let url = URL(string: "https://itunes.apple.com/lookup?bundleId=\(bundleId)&country=br") else { return }
            let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let data = data {
                do {
                    let jsonObject = try JSONSerialization.jsonObject(with: data)
                    guard let json = jsonObject as? [String: Any] else {
                        print("The received that is not a Dictionary")
                        return
                    }
                    let results = json["results"] as? [[String: Any]]
                    let firstResult = results?.first
                    let currentVersion = firstResult?["version"] as? String
                    print("currentVersion: ", currentVersion ?? "")
                } catch let serializationError {
                    print("Serialization Error: ", serializationError)
                }
            } else if let error = error {
                print("Error: ", error)
            } else if let response = response {
                print("Response: ", response)
            } else {
                print("Unknown error")
            }
        }
        task.resume()

    }
}

//    func getMultpleBusTrips(trips: [String], completion:@escaping ([String: BusTrip]) -> ()) {
//        guard let url = URL(string: "\(base_url)usa/nyc/bus/multiple-trips?APIKey=\(getApiKey())") else { return }
//
//        var request = URLRequest(url: url)
//        request.httpMethod = "POST"
//        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//        let parameters: [String: Any] = [
//            "trips": trips
//        ]
//        request.httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: .fragmentsAllowed)
//
//        print(parameters)
//
//        URLSession.shared.dataTask(with: request) { (data, _, _) in
//            let trips = try? JSONDecoder().decode([String: Trip].self, from: data ?? defaultTripsData)
//
//            completion(trips ?? exampleTrips)
//        }
//        .resume()
//    }






//class apiCallProduction {
//    func getStationTimes(station: String, completion:@escaping (NewTimes) -> ()) {
//        guard let url = URL(string: "\(base_url)stations/\(station)?APIKey=\(getApiKey())") else { return }
//        
//        URLSession.shared.dataTask(with: url) { (data, _, _) in
//            let times = try? JSONDecoder().decode(NewTimes.self, from: data ?? defaultStationTimeData)
//            
//            completion(times ?? defaultStationTimes)
//        }
//        .resume()
//    }
//    func getTrip(line: String, completion:@escaping ([String: Trip]) -> ()) {
//        guard let url = URL(string: "\(base_url)trips/\(line)?APIKey=\(getApiKey())") else { return }
//        
//        URLSession.shared.dataTask(with: url) { (data, _, _) in
//            let trips = try? JSONDecoder().decode([String: Trip].self, from: data ?? defaultTripsData)
//            
//            completion(trips ?? exampleTrips)
//        }
//        .resume()
//    }
//    func getIndividualTrip(trip: String, completion:@escaping (Trip) -> ()) {
//        guard let url = URL(string: "\(base_url)individual-trip/\(trip)?APIKey=\(getApiKey())") else { return }
//        print(trip)
//        
//        URLSession.shared.dataTask(with: url) { (data, _, _) in
//            let trips = try? JSONDecoder().decode(Trip.self, from: data ?? defaultTripData)
//            
//            completion(trips ?? exampleTrip)
//        }
//        .resume()
//    }
//    
//    func getStationAndTrips(station: String, completion: @escaping (TripAndStation) -> ()) {
//        guard let url = URL(string: "\(base_url)stations-with-trips/\(station)?APIKey=\(getApiKey())") else { return }
//                
//        URLSession.shared.dataTask(with: url) { (data, _, _) in
//            let tripAndStation = try? JSONDecoder().decode(TripAndStation.self, from: data ?? defaultTripAndStationData)
//            
//            DispatchQueue.main.async {
//                completion(tripAndStation ?? exampleTripAndStationData)
//            }
//        }
//        .resume()
//    }
//    
//    func getMultipleTrips(trips: [String], completion:@escaping ([String: Trip]) -> ()) {
//        guard let url = URL(string: "\(base_url)multiple-trips?APIKey=\(getApiKey())") else { return }
//        
//        var request = URLRequest(url: url)
//        request.httpMethod = "POST"
//        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//        let parameters: [String: Any] = [
//            "trips": trips
//        ]
//        request.httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: .fragmentsAllowed)
//        
//        print(parameters)
//
//        URLSession.shared.dataTask(with: request) { (data, _, _) in
//            let trips = try? JSONDecoder().decode([String: Trip].self, from: data ?? defaultTripsData)
//            
//            completion(trips ?? exampleTrips)
//        }
//        .resume()
//    }
//    func getAllServiceDisruptions(line: String, completion:@escaping ([String: Line_ServiceDisruption]) -> ()) {
//        guard let url = URL(string: "\(base_url)service-alerts/\(line)?APIKey=\(getApiKey())") else { return }
//        
//        URLSession.shared.dataTask(with: url) { (data, _, _) in
//            let trips = try? JSONDecoder().decode([String: Line_ServiceDisruption].self, from: data ?? defaultTripsData)
//            
//            completion(trips ?? exampleServiceAlerts)
//        }
//        .resume()
//    }
//    func getServiceDisruption(line: String, completion: @escaping (Line_ServiceDisruption) -> ()) {
//        guard let url = URL(string: "\(base_url)service-alerts/\(line)?APIKey=\(getApiKey())") else { return }
//        
//        URLSession.shared.dataTask(with: url) { (data, _, _) in
//            let trips = try? JSONDecoder().decode(Line_ServiceDisruption.self, from: data ?? defaultTripsData)
//            
//            completion(trips ?? exampleServiceAlert)
//        }
//        .resume()
//    }
//}
