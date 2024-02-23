//
//  sortedBusStop_time.swift
//  Service Bandage
//
//  Created by Conrad on 1/18/24.
//

import SwiftUI

struct sortedBusStop_times: View {
    var lines: [String]
    var times: [String: Bus_Times]
    var stop_ids: [String]
    
    var additionalHeight: CGFloat {
        if stop_ids.count == 2 {
            return 42
        }
        if stop_ids.count == 1 {
            return 8
        }
        return 0
    }
    
    var desiredRectHeight: CGFloat {
        var totalCount = 0
        if stop_ids.count > 1 {
            totalCount += (sortedTimes["direction 2"] ?? []).count
        }
        if stop_ids.count > 0 {
            totalCount += (sortedTimes["direction 1"] ?? []).count
        }
        
        if stop_ids.count == 2 {
            return CGFloat(totalCount * 43 + 84)
        }
        return CGFloat(totalCount * 43 + 24)
    }
    
    var sortedTimes: [String: [IndividualBusTime]] {
        return getSortedTimes()
    }
    
    @State private var showTimes = false
    @State private var buttonRotation: Double = 0.0
    @State private var rectHeight: CGFloat = 0
    
    @Environment(\.colorScheme) var colorScheme
    
    // need function here to sort times by arrival time instead of sorting by line vvvvvvvvvvvvvvvvvv
    
    func getSortedTimes() -> [String: [IndividualBusTime]] {
        var dictToReturn = [String: [IndividualBusTime]]()
        for stop_id in stop_ids {
            var label = "direction 1"
            
            if !dictToReturn.keys.contains(label) {
                dictToReturn[label] = []
            }
            
            if stop_ids.firstIndex(of: stop_id) == 1 {
                label = "direction 2"
                dictToReturn[label] = []
            }
            
            for line in lines {
                let timesy = times[stop_id]?.times?[line]??.keys
                
                if let allTimes = timesy {
                    for time in allTimes {
                        var entry = times[stop_id]?.times?[line]??[String(time)]
                        entry?.time = time
                        entry?.line = line
                        if let entry {
                            dictToReturn[label]?.append(entry)
                        }
                    }
                }
            }
        }
        
        for dictToReturnKey in Array(dictToReturn.keys) {
            dictToReturn[dictToReturnKey]?.sort {
                $0.time ?? "" < $1.time ?? ""
            }
            if dictToReturn[dictToReturnKey]?.count ?? 0 > 4 {
                let slice = dictToReturn[dictToReturnKey]?[0..<5]
                dictToReturn[dictToReturnKey]? = Array(slice ?? [])
            }
        }
//        print(dictToReturn)
        return dictToReturn
    }
    
    func checkIfCombined() -> Bool {
        if stop_ids.count == 2 {
            if busData_dictionary[stop_ids[0]]?.name ?? "" == busData_dictionary[stop_ids[1]]?.name ?? "" {
                return true
            }
        }
        return false
    }

    var body: some View {
        if stop_ids.count == 0 {
            Text("Something went wrong...")
        }
        else {
            ZStack {
                ZStack {
                    VStack {
                        Spacer()
                            .frame(height: 25)
                        bgColor.third.value
                            .environment(\.colorScheme,colorScheme)
                            .cornerRadius(10, corners: [.bottomLeft, .bottomRight])
                            .shadow(radius: 2)
                            .frame(height: rectHeight)
                            .padding(.horizontal, 6)
                        Spacer()
                    }
                    if rectHeight == desiredRectHeight {
                        VStack {
                            Spacer()
                                .frame(height: 42)
                            // MARK: - Consolidated
                            if Array(sortedTimes.keys).count == 2 {
                                LeadingText(text: "Direction 1", padding: 12)
                                    .padding(.top, 2)
                                    .padding(.bottom, -2)
                                ForEach(sortedTimes["direction 1"] ?? [], id: \.self) { entry in
                                    BusRow(
                                        line: entry.line ?? "",
                                        destination: entry.destination,
                                        time: Int(entry.time ?? "0") ?? 0,
                                        tripID: entry.tripID
                                    )
                                    .padding(.horizontal,12)
                                }
                                LeadingText(text: "Direction 2", padding: 12)
                                    .padding(.top,5)
                                    .padding(.top, 2)
                                    .padding(.bottom, -2)

                                ForEach(sortedTimes["direction 2"] ?? [], id: \.self) { entry in
                                    BusRow(
                                        line: entry.line ?? "",
                                        destination: entry.destination,
                                        time: Int(entry.time ?? "0") ?? 0,
                                        tripID: entry.tripID
                                    )
                                    .padding(.horizontal,12)
                                }
                            }
                            // MARK: - Non consolidated
                            else {
                                Spacer().frame(height: 8)
                                ForEach(sortedTimes["direction 1"] ?? [], id: \.self) { entry in
                                    BusRow(
                                        line: entry.line ?? "",
                                        destination: entry.destination,
                                        time: Int(entry.time ?? "0") ?? 0,
                                        tripID: entry.tripID
                                    )
                                    .padding(.horizontal,12)
                                }
                            }
                            Spacer()
                        }
                    }
                }
                VStack {
                    Button {
                        withAnimation(.spring(response: 0.31, dampingFraction: 0.74)) {
                            showTimes.toggle()
                            
                            if showTimes { rectHeight = desiredRectHeight; buttonRotation += 180 }
                            else { rectHeight = 0; buttonRotation -= 180 }
                        }
                    } label: {
                        VStack {
                            HStack {
                                Text(busData_dictionary[stop_ids[0]]?.name ?? "")
                                    .font(.title2)
                                Spacer()
                                Image(systemName: "chevron.up.circle.fill")
                                    .font(.title3)
                                    .rotationEffect(.degrees(buttonRotation))
                            }
                            .frame(height: 40)
                            .padding(.horizontal,6)
                            .background(
                                bgColor.third.value
                                    .environment(\.colorScheme,colorScheme)
                                    .cornerRadius(10)
                                    .shadow(radius: 2)
                                    .frame(height: 40)
                            )
                            .padding(.horizontal, 6)
                            .padding(.bottom, 4)
                            Spacer()
                        }
                    }
                    .frame(height: 40)
                    .buttonStyle(CButton())
                    Spacer()
                }
            }
            .frame(height: 40 + rectHeight + additionalHeight)
        }  // end of if statement
    }
}

struct sortedBusStop_time_previews: PreviewProvider {
    static var previews: some View {
        VStack {
            sortedBusStop_times(lines: ["M101", "M102", "M103"], times: defaultBusTimes_dict, stop_ids: ["401906","401991"])
            Spacer()
        }
        .previewLayout(.fixed(width: 375, height: 200))

    }
}
