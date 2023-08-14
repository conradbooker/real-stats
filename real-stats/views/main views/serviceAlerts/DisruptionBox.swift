//
//  DisruptionBox.swift
//  real-stats
//
//  Created by Conrad on 6/9/23.
//

import SwiftUI

extension Set {
    var array: [Element] {
        return Array(self)
    }
}

enum ServiceDisruption {
    case suspended, rerouted, delayed, skipped, local
}

func formattedSkippedStations(stations: [String]) -> String {
    var temp = ""
    temp += stationsDict[stations[0]]?.short1 ?? ""
    let newStations = stations[1...]
    for station in newStations {
        temp += ", \(stationsDict[station]?.short1 ?? "")"
    }
    return temp
}

func getAllStations(stations: [String]) -> String {
    var temp = ""
    temp += "\(stationsDict[stations[0]]?.short1 ?? "")"
    if stations.count > 1 {
        for station in stations[1...] {
            temp += ", \(stationsDict[station]?.short1 ?? "")"
        }
    }
    return temp
}

func formattedLocalBoros(stations: [String]) -> String {
    var boros: Array<String> = Array<String>()
    var temp = ""
    
    for station in stations {
        if stationsDict[station]?.boro ?? "" == "M" {
            if !(boros.contains("Manhattan")) {
                boros.append("Manhattan")
            }
        } else if stationsDict[station]?.boro ?? "" == "Bk" {
            if !(boros.contains("Brooklyn")) {
                boros.append("Brooklyn")
            }
        } else if stationsDict[station]?.boro ?? "" == "Bx" {
            if !(boros.contains("The Bronx")) {
                boros.append("The Bronx")
            }
        } else if stationsDict[station]?.boro ?? "" == "Q" {
            if !(boros.contains("Queens")) {
                boros.append("Queens")
            }
        }
    }
    temp += boros[0]
    if boros.count > 1 {
        let newBoros = boros[1...]
        for boro in newBoros {
            temp += ", \(boro)"
        }
    }
    
    return temp
}

struct DisruptionBox: View {
    var type: ServiceDisruption
    
    var trip: Trip
    var reroute: Reroute
    var from: String = ""
    var to: String = ""
    var stationsArray: [String] = [String]()
    var suspended: [String]
    
    init(type: ServiceDisruption, trip: Trip, reroute: Reroute, suspended: [String]) {
        self.type = type
        self.trip = trip
        self.reroute = reroute
        self.suspended = suspended
        
        if type == .rerouted {
            self.from = reroute.reroutedFrom
            self.from = stationsDict[from]?.short1 ?? ""
            
            self.to = reroute.reroutedTo
            self.to = stationsDict[to]?.short1 ?? ""
        } else if type == .suspended {
            self.from = suspended[0]
            self.from = stationsDict[from]?.short1 ?? ""
            
            self.to = suspended[1]
            self.to = stationsDict[to]?.short1 ?? ""
        } else if type == .skipped {
            stationsArray = trip.serviceDisruptions.skippedStations ?? [String]()
        } else if type == .local {
            stationsArray = trip.serviceDisruptions.localStations ?? [String]()
        }
    }
    
    var body: some View {
        if type == .rerouted {
            if reroute.sudden {
                VStack(alignment: .leading, spacing: 0) {
                    HStack(spacing: 0) {
                        Text("Sudden reroute via")
                            .padding(4)
                        Image(reroute.via)
                            .resizable()
                            .frame(width: 16, height: 16)
                    }
                    Text("from **\(from)** to **\(to)**")
                        .padding(.horizontal,4)
                }
            } else {
                VStack(alignment: .leading, spacing: 0) {
                    HStack(spacing: 0) {
                        Text("Running via")
                            .padding(4)
                        Image(reroute.via)
                            .resizable()
                            .frame(width: 16, height: 16)
                    }
                    Text("from **\(from)** to **\(to)**")
                        .padding(.horizontal,4)
                }

            }
        } else if type == .suspended {
            VStack(alignment: .leading, spacing: 0) {
                HStack(spacing: 0) {
                    Text("Not running from **\(from)** to **\(to)**")
                        .padding(4)
                }
            }
        } else if type == .skipped {
            VStack(alignment: .leading, spacing: 0) {
                HStack(spacing: 0) {
                    Text("**Skipping**: \(formattedSkippedStations(stations: stationsArray))")
                        .padding(4)
                }
            }
        } else if type == .local {
            VStack(alignment: .leading, spacing: 0) {
                HStack(spacing: 0) {
                    Text("**Running Local** in: \(formattedLocalBoros(stations: stationsArray))")
                        .padding(4)
                }
            }
        }
    }
}

struct DisruptionBox_Previews: PreviewProvider {
    static var previews: some View {
        DisruptionBox(type: .rerouted, trip: exampleTrip, reroute: (exampleTrips["052900_W..S"]?.serviceDisruptions.reroutes[0])!, suspended: ["",""])
            .previewLayout(.fixed(width: 150, height: 80))
    }
}
