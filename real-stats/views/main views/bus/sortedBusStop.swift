//
//  sortedBusStop.swift
//  Service Bandage
//
//  Created by Conrad on 1/18/24.
//

import SwiftUI

let defaultBusTimes_dict_large = [
    "401091": defaultBusTimes,
    "401092": defaultBusTimes,
    "401090": defaultBusTimes,
    "401029": defaultBusTimes,
    "401334": defaultBusTimes,
    "401256": defaultBusTimes,
    "401335": defaultBusTimes,
    "401257": defaultBusTimes,
    "404320": defaultBusTimes,
    "401030": defaultBusTimes,
    "401333": defaultBusTimes,
    "401255": defaultBusTimes,
    "401336": defaultBusTimes,
    "401258": defaultBusTimes,
    "403111": defaultBusTimes,
    "401936": defaultBusTimes,
    "404308": defaultBusTimes,
    "404075": defaultBusTimes,
    "401898": defaultBusTimes,
    "403159": defaultBusTimes,
    "401254": defaultBusTimes
]

let defaultBusTimes_dict = ["401906": defaultBusTimes, "401921": defaultBusTimes]
let defaultBusTimes =  Bus_Times(service: true, times: defaultTimesForBus)

let defaultTimesForBus: [String: [String: IndividualBusTime]] = [
    "M101": [
        "1705779137": IndividualBusTime(tripID: "AB*M101", destination: "401331", next_stops: ["403777","401946","403436","405181","402502"])
    ],
    "M102": [
        "1705779237": IndividualBusTime(tripID: "AB*M102", destination: "401331", next_stops: ["402696","402697","403765","403777","401946"]),
        "1705779337": IndividualBusTime(tripID: "AB*M102", destination: "401331", next_stops: ["402696","402697","403765","403777","401946"]),
    ],
    "M103": [
        "1705779437": IndividualBusTime(tripID: "AB*M103", destination: "401331", next_stops: ["402696","402697","403765","403777","401946"]),
    ]
]

struct sortedBusStop: View {
    var lines: [String]
    var times: [String: Bus_Times]
    var stop_ids: [String]
    
    var consolidatedStop: Bool {
        if stop_ids.count == 2 {
            return (busData_dictionary[stop_ids[0]]?.name ?? "" ==
                    busData_dictionary[stop_ids[1]]?.name ?? "")
        }
        return false
    }
    
    @Environment(\.colorScheme) var colorScheme
    
    func line_cleaned(_ line: String) -> String {
        if line.contains("_ltd") {
            var newLine = line
            newLine.removeLast(4)
            return newLine
        }
        return line
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                ForEach(lines, id: \.self) { line in
                    Text(line_cleaned(line))
                        .font(.title)
                        .padding(2)
                        .padding(.horizontal,2)
                        .foregroundColor(getCorrectColor(route: line)[0])
                        .background(
                            getCorrectColor(route: line)[1]
                                .cornerRadius(4)
                                .shadow(radius: 2)
                            
                        )
                        .padding([.leading, .top],6)
                }
                Spacer()
            }
            Spacer().frame(height: 9)
            if stop_ids.count == 2 {
                Spacer().frame(height: 6)
                if consolidatedStop {
                    sortedBusStop_times(lines: lines, times: times, stop_ids: stop_ids)
                        .padding(.vertical, 3)
                        .padding(.bottom, -40)
                } else {
                    ForEach(stop_ids, id: \.self) { stop_id in
                        sortedBusStop_times(lines: lines, times: times, stop_ids: [stop_id])
                            .padding(.vertical, 3)
                    }
                }
            } else {
                ForEach(stop_ids, id: \.self) { stop_id in
                    sortedBusStop_times(lines: lines, times: times, stop_ids: [stop_id])
                        .padding(.vertical, 3)
                }
            }
//            Spacer()
        }
    }
}

struct sortedBusStop_previews: PreviewProvider {
    static var previews: some View {
        
        sortedBusStop(lines: ["M101", "M102"], times: defaultBusTimes_dict, stop_ids: ["401906"])
            .previewLayout(.fixed(width: 375, height: 200))
    }
}
