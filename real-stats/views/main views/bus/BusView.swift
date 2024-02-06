//
//  BusView.swift
//  Service Bandage
//
//  Created by Conrad on 1/20/24.
//

import SwiftUI
import CoreLocation
import Reachability

struct SortedBusStop: Hashable, Codable {
    var lines: [String]
    var times: [String: Bus_Times] // all of the stop times [stop_id: bus_time]
    var stop_ids: [String]
}

let default_sortedBusStop = SortedBusStop(lines: ["M101", "M102"], times: defaultBusTimes_dict, stop_ids: ["401906","401921"])

// STOPS TO SIMULATE: 403434 (3 av/ 86 st), 403419 (lex av / 86)
// 401906 (86 st / 3 av), 401921 (86 st / 3 av)


struct BusView: View {
    var coordinate: CLLocationCoordinate2D
    var counter: Double?
    
    @State private var sortedBusStops: [SortedBusStop] = []
    
    func getNearByBusStops(coordinate: CLLocationCoordinate2D) -> [String] {
        let currentLoc = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        let stations = busData_array
            .sorted(by: {
                return $0.location.distance(from: currentLoc) < $1.location.distance(from: currentLoc)
            })
        var newStations = [String]()
        
        for num in 0...40 {
            newStations.append(stations[num].id)
        }
                
        return newStations
    }
    
    func apiCall() {
        loading = true
        bus_API_Call().getMultipleStops(stop_ids: getNearByBusStops(coordinate: coordinate)) { (stop_dict) in
            var lines = [String: [String]]()
            for stop in Array(stop_dict.keys) {
                let keys = Array(stop_dict[stop]?.times?.keys ?? [:].keys)
                
                for line in keys {
                    let newLine = String(line)
                    if !Array(lines.keys).contains(line) {
                        lines[newLine] = [String(stop)]
                    } else {
                        lines[newLine]?.append(String(stop))
                    }
                }
            }

            var finalBusDict = [String: [String: [String]]]()
            let currentLoc = CLLocation(latitude: coordinate.latitude , longitude: coordinate.longitude )
            
            for entry in lines {

                let sortedBusStops = entry.value.sorted(by: { (stop1, stop2) in
                    let location1 = busData_dictionary[stop1]?.location
                    let location2 = busData_dictionary[stop2]?.location
                    
                    return location1?.distance(from: currentLoc) ?? 0 < location2?.distance(from: currentLoc) ?? 0
                })
                
                let closestStop = sortedBusStops.first
                let current_line = String(entry.key)
                                
//                print(closestStop ?? "", "hi", busData_dictionary[closestStop ?? ""]?.name ?? "")
                
                                        //   stop id: [time: [next stops]]
                var stops_with_next_stops = [String: [String: [String]]]()
                for stop in sortedBusStops { // stops for line
                    stops_with_next_stops[stop] = [String: [String]]()
                    let allTimes = stop_dict[stop]?.times?[current_line] ?? [:]
                    
                    for time in allTimes ?? [:] {
                        let next_stops = time.value.next_stops
                        let time_int = time.key
                        stops_with_next_stops[stop]?[time_int] = next_stops
                        
//                        print("fuck",entry.key, key, next_stops)
//                        hi
                    }
                }
//                print(current_line, stops_with_next_stops)
                
                let firstStation_nextStops = stops_with_next_stops[closestStop ?? ""] ?? [:]
                var local_nextStops = [String]()
                
                var allTimeKeys = Array(firstStation_nextStops.keys).sorted()
                let firstTime_nextStops = firstStation_nextStops[allTimeKeys.first ?? ""]
                allTimeKeys.removeFirst()
                
                local_nextStops = firstTime_nextStops ?? []
                
//                print(allTimeKeys.first, firstTime_nextStops)
                for time in allTimeKeys {
                    let nextStops = firstStation_nextStops[time]
                    
                    let firstTime_nextStops_SET = Set<String>(firstTime_nextStops ?? [])
                    let secondTime_nextStops_SET = Set<String>(nextStops ?? [])
                    
                    let intersection = Array(firstTime_nextStops_SET.intersection(secondTime_nextStops_SET))
                    
                    if intersection.count > 0 {
                        // if intersection is towards the end of the first and begininning of second, then  firs is local, second is limited
                        // visa versa
                    } else {
                        if nextStops?.count ?? 0 > local_nextStops.count {
                            local_nextStops = nextStops ?? []
//                            print("EEEEEEEE")
                        }
                    }
                }
                
                finalBusDict[entry.key] = [String(closestStop ?? ""): local_nextStops]
                
                for stop in sortedBusStops {
                    if stop != closestStop {
                        let firstStation_nextStops_current = stops_with_next_stops[stop ] ?? [:]
                        var local_nextStops_current = [String]()
                        
                        var allTimeKeys_current = Array(firstStation_nextStops_current.keys).sorted()
                        let firstTime_nextStops_current = firstStation_nextStops_current[allTimeKeys_current.first ?? ""]
                        allTimeKeys_current.removeFirst()
                        
                        local_nextStops_current = firstTime_nextStops_current ?? []
                        
        //                print(allTimeKeys.first, firstTime_nextStops)
                        for time in allTimeKeys_current {
                            let nextStops_current = firstStation_nextStops_current[time]
                            
                            let firstTime_nextStops_SET_current = Set<String>(firstTime_nextStops_current ?? [])
                            let secondTime_nextStops_SET_current = Set<String>(nextStops_current ?? [])
                            
                            let intersection_current = Array(firstTime_nextStops_SET_current.intersection(secondTime_nextStops_SET_current))
                            
                            if intersection_current.count > 0 {
                                // if intersection is towards the end of the first and begininning of second, then  firs is local, second is limited
                                // visa versa
                            } else {
                                if nextStops_current?.count ?? 0 > local_nextStops_current.count {
                                    local_nextStops_current = nextStops_current ?? []
                                }
                            }
                        }
                        
                        
                        let local_nextStops_original_SET = Set<String>(local_nextStops)
                        let intersection_localStops = local_nextStops_original_SET.intersection(local_nextStops_current)

//                        print(entry.key, "original next stops (original key is \(closestStop ?? "")):", local_nextStops, "current next stops:", local_nextStops_current, "INTERSECTION IS", intersection_localStops)

                        if local_nextStops_current.contains(closestStop ?? "") {
                            continue
                        } else if intersection_localStops.count > 0 {
                            continue
                        } else if intersection_localStops.count == 0 {
                            
//                            print("OPPOSITE DIRECTION")
                            finalBusDict[entry.key]?[stop] = local_nextStops_current
                            break
                        }
//                        print(intersection_localStops)
                    }
                }
                // combine like stops
            }
            
//            print(finalBusDict)
            
            var completedLines = [String]()
            var sortedBusStops_final = [SortedBusStop]()
            
            for line1 in finalBusDict {
                if !completedLines.contains(line1.key) {
                    var finalBusDictWithout1 = finalBusDict
                    finalBusDictWithout1.removeValue(forKey: line1.key)
                    var linesToCombine = [line1.key]
                    
                    let line1StopKeys = Set<String>(line1.value.keys)
                    for line2 in finalBusDictWithout1 {
                        let line2StopKeys = Set<String>(line2.value.keys)
                        
                        if line1StopKeys.intersection(line2StopKeys).count > 1 || (line1StopKeys.count == 1 && line2StopKeys.count == 1 && line1StopKeys.intersection(line2StopKeys).count == 1) {
                            linesToCombine.append(line2.key)
                            completedLines.append(line2.key)
                        }
                    }
                    
                    let newSortedBusStop = SortedBusStop(lines: linesToCombine.sorted(by: <), times: stop_dict, stop_ids: Array(line1StopKeys))
                    sortedBusStops_final.append(newSortedBusStop)
                    completedLines.append(line1.key)
                }
            }
            
            self.sortedBusStops = sortedBusStops_final.sorted(by: {(sortedStop1, sortedStop2) in
                let location1 = busData_dictionary[sortedStop1.stop_ids.first ?? ""]?.location
                let location2 = busData_dictionary[sortedStop2.stop_ids.first ?? ""]?.location
                
                return location1?.distance(from: currentLoc) ?? 0 < location2?.distance(from: currentLoc) ?? 0
            })
            loading = false
        }
        
        
    }
    
    private func checkInternetConnection() {
        guard let reachability = try? Reachability() else {
            return
        }

        if reachability.connection != .unavailable {
            isInternetConnected = true
        } else {
            isInternetConnected = false
            loading = false
        }
    }

    @State private var isInternetConnected = true
    
    @State private var loading = true

    var body: some View {
        LazyVStack {
            if loading {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .foregroundColor(Color("cLessDarkGray"))
                        .shadow(radius: 2)
                        .frame(height: 100)
                        .padding()
                    HStack {
                        ActivityIndicator()
                            .frame(width: 80, height: 80)
                            .padding()
                        Text(String(format: NSLocalizedString("loading", comment: "")))
                            .font(.headline)
                            .fontWeight(.semibold)
                            .padding(5)
                            .frame(width: UIScreen.screenWidth / 2)
                    }
                }
                .onAppear {
                    apiCall()
                    checkInternetConnection()
                }
            } else {
                ScrollView {
                    if isInternetConnected {
                        ForEach(sortedBusStops, id: \.self) { stop in
                            sortedBusStop(lines: stop.lines, times: stop.times, stop_ids: stop.stop_ids)
                            Spacer().frame(height: 20)
                        }
                    } else {
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .foregroundColor(Color("cLessDarkGray"))
                                .shadow(radius: 2)
                                .frame(height: 100)
                                .padding()
                            HStack {
                                Image(systemName: "wifi.slash")
                                    .foregroundStyle(.red, .black)
                                    .font(.system(size: 60))
                                    .shadow(radius: 2)
                                    .padding()
                                Text(String(format: NSLocalizedString("no-connection", comment: "")))
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                    .padding(5)
                                    .frame(width: UIScreen.screenWidth / 2)
                            }
                        }
                    }
                    Image(systemName: "c.circle.fill")
                        .onChange(of: counter) { _ in
                            apiCall()
                            checkInternetConnection()
                        }
                        .hidden()
                    Spacer().frame(height: 200)
                }
            }
        }
    }
}

struct BusView_Previews: PreviewProvider {
    static var previews: some View {
        BusView(coordinate: CLLocationCoordinate2D(latitude: 40.78969, longitude: -73.96986))
    }
}
