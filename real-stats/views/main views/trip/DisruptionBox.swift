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
func formattedLocalBoros(stations: [String]) -> String {
    var boros: Set<String> = Set<String>()
    var temp = ""
    
    for station in stations {
//        temp += ", \(stationsDict[station]?.boro ?? "")"
        if stationsDict[station]?.boro ?? "" == "M" {
            boros.insert("Manhattan")
        } else if stationsDict[station]?.boro ?? "" == "Bk" {
            boros.insert("Brooklyn")
        } else if stationsDict[station]?.boro ?? "" == "Bx" {
            boros.insert("Bronx")
        } else if stationsDict[station]?.boro ?? "" == "Q" {
            boros.insert("Queens")
        }
    }
    for boro in boros {
        temp += ", \(boro)"
    }
    return temp
}

struct DisruptionBox: View {
    var type: ServiceDisruption
    
    var tripID: String
    var trips: [String: Trip]
    var reroute: Reroute
    var from: String = ""
    var to: String = ""
    var stationsArray: [String] = [String]()
    var suspended: [String]
    
    init(type: ServiceDisruption, tripID: String, trips: [String : Trip], reroute: Reroute, suspended: [String]) {
        self.type = type
        self.tripID = tripID
        self.trips = trips
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
            stationsArray = trips[tripID]?.serviceDisruptions.skippedStations ?? [String]()
        } else if type == .local {
            stationsArray = trips[tripID]?.serviceDisruptions.localStations ?? [String]()
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
                    Text("**Running Local** in\(formattedLocalBoros(stations: stationsArray))")
                        .padding(4)
                }
            }
        }
    }
}

struct DisruptionBox_Previews: PreviewProvider {
    static var previews: some View {
        DisruptionBox(type: .rerouted, tripID: "052900_W..S", trips: exampleTrips, reroute: (exampleTrips["052900_W..S"]?.serviceDisruptions.reroutes[0])!, suspended: ["",""])
            .previewLayout(.fixed(width: 150, height: 80))
    }
}
