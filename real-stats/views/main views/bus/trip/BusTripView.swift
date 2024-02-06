//
//  BusTripView.swift
//  Service Bandage
//
//  Created by Conrad on 2/3/24.
//

import SwiftUI

//let defaultBusTrip = BusTrip(
//    line: "M86+",
//    stations: defaultBusTimes,
//    destination: T##String,
//    delay: T##Int)


func getTripStationKeys_Bus(stations: [String: BusStop_Time], all: Bool) -> [String] {
    var arr = [String]()
    var triggered = false
    var triggered2 = false
    var notAll = false
    
    var stationBefore = ""
    var firstStation = ""

    let sortedStations = stations.sorted { $0.value.times[0] < $1.value.times[0] }
    for station in sortedStations {
        if !triggered2 {
            triggered2 = true
            firstStation = station.key
            if station.value.times[0] > Int(Date().timeIntervalSince1970) {
                notAll = true
            }
        }
        if all || notAll {
            arr.append(station.key)
        } else {
            if station.value.times[0] > Int(Date().timeIntervalSince1970) {
                if !triggered && stationBefore != "" {
                    triggered = true
                    arr.append(firstStation)
                    arr.append(stationBefore)
                }
                arr.append(station.key)
            }
            stationBefore = station.key
        }
    }
    return arr
}

func getCurrentStation_Bus(stations: [String: BusStop_Time]) -> String {
    let sortedStations = stations.sorted { $0.value.times[0] < $1.value.times[0] }
    
    for station in sortedStations {
        if station.value.times[0] > Int(Date().timeIntervalSince1970) {
            if  station.value.times[0] - Int(Date().timeIntervalSince1970) < 20 {
                return "@ \(busData_dictionary[station.key]?.name ?? "")"
            } else {
                return "→ \(busData_dictionary[station.key]?.name ?? "")"
            }
        }
    }
    return "Trip is completed!"
}

func getCurrentStationClean_Bus(stations: [String: BusStop_Time]) -> String {
    let sortedStations = stations.sorted { $0.value.scheduledTime < $1.value.scheduledTime }
    
    for station in sortedStations {
        if station.value.times[0] - 20 - Int(Date().timeIntervalSince1970) <= 20 && station.value.times[0] - Int(Date().timeIntervalSince1970) > 0 {
            return station.key
        }
    }
    return ""
}

func getStationBefore_Bus(stations: [String: BusStop_Time]) -> String {
    let sortedStations = stations.sorted { $0.value.scheduledTime < $1.value.scheduledTime }
    
    var stationBefore = ""
    
    for station in sortedStations {
        if station.value.times[0] - 20 - Int(Date().timeIntervalSince1970) > 20 {
            return stationBefore
        }
        stationBefore = station.key
    }
    return stationBefore
}


struct BusTripView: View {
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var tripID: String
    
    @State private var all: Bool = false
    @State private var trip: BusTrip?
    @State private var stationKeys: [String] = []
    @State private var counter = 0
    
    var line: String {
        return trip?.line ?? ""
    }
    
    var statusText: String {
        return getCurrentStation_Bus(stations: trip?.stations ?? [:])
    }
    
    var delayAmmount: Int {
        return trip?.delay ?? 0
//        return 120
    }
    
    var destination: String {
        return busData_dictionary[trip?.destination ?? ""]?.name ?? ""
    }
    
    var delayAmmountReadable: String {
        let minutes = Double(delayAmmount) / 60.0
        let roundedMinutes = (minutes * 2).rounded() / 2
        
        let isWholeNumber = roundedMinutes.truncatingRemainder(dividingBy: 1) == 0
        
        // Format the result accordingly
        let formattedMinutes: String
        if isWholeNumber {
            formattedMinutes = String(format: "%.0f", roundedMinutes)
        } else {
            formattedMinutes = String(format: "%.1f", roundedMinutes)
        }

        if roundedMinutes == 1 {
            return "1 min"
        }
        return "\(formattedMinutes) mins"
    }
    
    var line_cleaned: String {
        if line.contains("_ltd") {
            var newLine = line
            newLine.removeLast(4)
            return newLine
        }
        return line
    }

    
    var body: some View {
        ZStack {
// MARK: - START Bottom Section
            ScrollView {
                Spacer()
                    .frame(height: 107)
                    .onReceive(timer) { _ in
                        withAnimation(.spring(response: 0.4)) {
                            counter += 1
                        }
                    }
                HStack {
                    Button {
                        all.toggle()
                        withAnimation(.spring(response: 0.4)) {
                            stationKeys = getTripStationKeys_Bus(stations: trip?.stations ?? [:], all: all)
                        }
                    } label: {
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .frame(width: 130, height: 30)
                                .foregroundColor(Color("cLessDarkGray"))
                                .shadow(radius: 2)
                            if all {
                                Text("Fewer stations")
                            } else {
                                Text("More stations")
                            }
                        }
                    }
                    .padding(.horizontal)
                    .buttonStyle(CButton())
                    // end of button
                    
                    Spacer()
                        .onAppear {
                            withAnimation(.spring(response: 0.4)) {
                                bus_API_Call().getIndividualTrip(trip: tripID) { (tripy) in
                                    trip = tripy
                                    stationKeys = getTripStationKeys_Bus(stations: trip?.stations ?? [:], all: false)
                                }
                            }
                        }
                }
                ZStack {
                    VStack(spacing: 0) {
                        Spacer()
                            .frame(height: 20)
                        ForEach(stationKeys, id: \.self) { station in
                            HStack(spacing: 0) {
                                VStack(spacing: 0) {
                                    if getTripStationKeys_Bus(stations: trip?.stations ?? [:] , all: true).first == station && !all {
                                        Rectangle()
                                            .frame(width: 16, height: 10)
                                            .foregroundColor(getLineColor_Bus(line: line, time: trip?.stations[station]?.times[0] ?? 0))
                                            .padding(.horizontal,18)
                                        Rectangle()
                                            .frame(width: 16, height: 5)
                                            .foregroundColor(getLineColor_Bus(line: line, time: trip?.stations[station]?.times[0] ?? 0))
                                            .padding(.horizontal,18)
                                            .opacity(0)

                                        Rectangle()
                                            .frame(width: 16, height: 5)
                                            .foregroundColor(getLineColor_Bus(line: line, time: trip?.stations[station]?.times[0] ?? 0))
                                            .padding(.horizontal,18)
                                        Rectangle()
                                            .frame(width: 16, height: 5)
                                            .foregroundColor(getLineColor_Bus(line: line, time: trip?.stations[station]?.times[0] ?? 0))
                                            .padding(.horizontal,18)
                                            .opacity(0)

                                        Rectangle()
                                            .frame(width: 16, height: 5)
                                            .foregroundColor(getLineColor_Bus(line: line, time: trip?.stations[station]?.times[0] ?? 0))
                                            .padding(.horizontal,18)
                                        Rectangle()
                                            .frame(width: 16, height: 5)
                                            .foregroundColor(getLineColor_Bus(line: line, time: trip?.stations[station]?.times[0] ?? 0))
                                            .padding(.horizontal,18)
                                            .opacity(0)

                                        Rectangle()
                                            .frame(width: 16, height: 5)
                                            .foregroundColor(getLineColor_Bus(line: line, time: trip?.stations[station]?.times[0] ?? 0))
                                            .padding(.horizontal,18)

                                        Rectangle()
                                            .frame(width: 16, height: 25)
                                            .foregroundColor(getLineColor_Bus(line: line, time: trip?.stations[station]?.times[0] ?? 0))
                                            .padding(.horizontal,18)
                                    } else if getTripStationKeys_Bus(stations: trip?.stations ?? [:] , all: true).last == station {
                                        
                                    } else {
                                        Rectangle()
                                            .frame(width: 16, height: 70)
                                            .foregroundColor(getLineColor_Bus(line: line, time: trip?.stations[station]?.times[0] ?? 0))
                                            .padding(.horizontal,18)
                                    }
                                }
                                Spacer()
                            }
                        }
                        Spacer()
                    }
                    VStack(spacing: 0) {
                        ForEach(stationKeys, id: \.self) { station in
                            BusTrip_Stop(
                                station: station, line: line, trip: trip ?? defaultBusTrip, counter: counter
                            )
                            .frame(height: 70)
                            
                        }
                    }
                }

            }
// MARK: - END Bottom Section
            
            
            
            
// MARK: - START Top Section
            ZStack {
                VStack {
                    Rectangle()
                        .frame(height: 90)
                        .foregroundColor(Color("cDarkGray"))
                        .shadow(radius: 2)
                    Spacer()
                }
                VStack(spacing: 0) {
                    Capsule()
                        .fill(Color("second"))
                        .frame(width: 34, height: 4.5)
                        .padding(.top, -10)
                    HStack {
                        Text(line_cleaned)
                            .font(.title2)
                            .padding(2)
                            .padding(.horizontal, 2)
                        
                            .foregroundColor(getCorrectColor(route: line)[0])
                            .background(
                                getCorrectColor(route: line)[1]
                                    .background(.ultraThinMaterial)
                                    .cornerRadius(4)
                                    .shadow(radius: 2)
                                
                            )
                            .padding(.top, 6)
                        Spacer().frame(width: 8)
                        Text("to \(destination)")
                            .font(.title3)
                            .fontWeight(.bold)
                            .padding(.bottom, -5)
                        
                        Spacer()
                        Button {
                            withAnimation(.spring(response: 0.4)) {
                                bus_API_Call().getIndividualTrip(trip: tripID) { (tripy) in
                                    trip = tripy
                                }
                            }
                        } label: {
                            ZStack {
                                RoundedRectangle(cornerRadius: 10)
                                    .frame(width: 30, height: 30)
                                    .foregroundColor(Color("cLessDarkGray"))
                                    .shadow(radius: 2)
                                Image(systemName: "arrow.clockwise")
                            }
                        }
                        .buttonStyle(CButton())
                    }
                    Spacer().frame(height: 7)
                    // MARK: - Delay
                    if delayAmmount < 60 {
                        HStack {
                            Text(statusText)
                                .font(.subheadline)
                            Spacer()
                        }
                        .padding(.vertical, 2)
                    } else {
                        HStack {
                            Text("Delayed \(statusText) for \(delayAmmountReadable)")
                                .font(.subheadline)
                            Spacer()
                        }
                        .padding(.vertical, 2)
                    }
                    Spacer()
                }
                .padding()
            }
// MARK: - END Bottom Section

        }
    }
}

struct BusTripView_Previews: PreviewProvider {
    static var previews: some View {
        BusTripView(tripID: "hi")
    }
}
