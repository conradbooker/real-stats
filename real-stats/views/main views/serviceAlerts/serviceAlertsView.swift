//
//  serviceAlertsView.swift
//  Service Bandage
//
//  Created by Conrad on 7/30/23.
//

import SwiftUI

struct serviceAlertsView: View {
    var line: String
    @State var direction: String
    @State var textSize = CGSize()
    
    @State var alerts: Line_ServiceDisruption = load("exampleServiceDisruption.json")
    
    func getSuspensionKeys(_ dict: [String: Line_ServiceDisruption_Suspended]) -> [String] {
        var keys = [String]()
        for key in dict {
            keys.append(key.key)
        }
        
        return keys
    }
    func getLocalStationKeys(_ dict: [String: Line_ServiceDisruption_Local]) -> [String] {
        var keys = [String]()
        for key in dict {
            keys.append(key.key)
        }
        
        return keys
    }
    func getSkippedStationKeys(_ dict: [String: Line_ServiceDisruption_Skipped]) -> [String] {
        var keys = [String]()
        for key in dict {
            keys.append(key.key)
        }
        
        return keys
    }
    func getRerouteKeys(_ dict: [String: Line_ServiceDisruption_Reroutes]) -> [String] {
        var keys = [String]()
        for key in dict {
            keys.append(key.key)
        }
        
        return keys
    }
    func getDelayKeys(_ dict: [String: Line_ServiceDisruption_Delay]) -> [String] {
        var keys = [String]()
        for key in dict {
            keys.append(key.key)
        }
        
        return keys
    }

    init(line: String, direction: String) {
        self.line = line
        self._direction = State(initialValue: direction)
    }
    
    var body: some View {
        GeometryReader { geometry in
        ZStack {
            Color("cDarkGray")
                .ignoresSafeArea()
            VStack {
                Spacer().frame(height: 120)
                ScrollView {
                    if (direction == "north") {
//                        HStack {
//                            Text("Delays:")
//                                .padding(.horizontal)
//                            Spacer()
//                        }
                        ForEach(getDelayKeys(alerts.northbound.delays ?? [String: Line_ServiceDisruption_Delay]()), id: \.self) { alert in
                            if alerts.northbound.delays?[alert]?.delayAmmount ?? 0 > 120 {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 10)
                                        .foregroundColor(Color("cLessDarkGray"))
                                        .shadow(radius: 2)
                                        .frame(width: geometry.size.width-20,height: 60)
                                        .padding(.top,3)
//                                        .padding()
                                    HStack {
                                        Image(systemName: "clock.badge.exclamationmark.fill")
                                            .foregroundStyle(.yellow, Color("whiteblack"))
                                            .padding(2)
                                            .padding(.leading,17)
                                            .font(.system(size: 30))
                                        

                                        VStack(alignment: .leading) {
                                            HStack(spacing: 0) {
                                                Image(line)
                                                    .resizable()
                                                    .frame(width: 16, height: 16)
                                                    .padding(.leading, 5)
                                                Text("train to \(stationsDict[alerts.northbound.delays?[alert]?.destination ?? ""]?.short1 ?? "") has been stalled")
                                                    .padding(4)
                                            }
                                            Text("at \(stationsDict[alerts.northbound.delays?[alert]?.location ?? ""]?.short1 ?? "") for \((alerts.northbound.delays?[alert]?.delayAmmount ?? 0)/60) minutes.")
                                                .padding(.top,-10)
                                                .padding(.leading, 5)
                                        }
                                        .padding(.leading, 6)
                                        Spacer()
                                    }
                                }
//                                .frame(width: geometry.size.width,height: 60)
                            }
                        }

//                        HStack {
//                            Text("Suspensions:")
//                                .padding(.horizontal)
//                            Spacer()
//                        }
                        ForEach(getSuspensionKeys(alerts.northbound.suspended ?? [String: Line_ServiceDisruption_Suspended]()), id: \.self) { alert in
                            if alerts.northbound.suspended?[alert]?.occurances ?? 0 > 2 {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 10)
                                        .foregroundColor(Color("cLessDarkGray"))
                                        .shadow(radius: 2)
                                    HStack {
                                        Image(systemName: "xmark.octagon.fill")
                                            .foregroundStyle(.white, .red)
                                            .padding(2)
                                            .padding(.leading,10)
                                            .font(.system(size: 30))
                                        

                                        VStack(alignment: .leading) {
                                            Text("**Not Running** from **\(stationsDict[alerts.northbound.suspended?[alert]?.stations[0] ?? ""]?.short1 ?? "")** to **\(stationsDict[alerts.northbound.suspended?[alert]?.stations[1] ?? ""]?.short1 ?? "")**")
                                        }
                                        .padding(.leading, 6)
                                        Spacer()
                                    }
                                }
                                .frame(width: geometry.size.width-20,height: 60)
                            }
                        }
//                        HStack {
//                            Text("Reroutes:")
//                                .padding(.horizontal)
//                            Spacer()
//                        }
                        ForEach(getRerouteKeys(alerts.northbound.reroutes ?? [String: Line_ServiceDisruption_Reroutes]()), id: \.self) { alert in
                            if alerts.northbound.reroutes?[alert]?.occurances ?? 0 > 2 {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 10)
                                        .foregroundColor(Color("cLessDarkGray"))
                                        .shadow(radius: 2)
                                    HStack {
                                        Image(systemName: "point.topleft.down.curvedto.point.filled.bottomright.up")
                                            .padding(2)
                                            .padding(.leading,15)
                                            .font(.system(size: 30))
                                        VStack(alignment: .leading, spacing: 0) {
                                            HStack(spacing: 0) {
                                                Text("Running via")
                                                    .padding(4)
                                                Image(alerts.northbound.reroutes?[alert]?.via ?? "")
                                                    .resizable()
                                                    .frame(width: 16, height: 16)
                                            }
                                            Text("from **\(stationsDict[alerts.northbound.reroutes?[alert]?.reroutedFrom ?? ""]?.short1 ?? "")** to **\(stationsDict[alerts.northbound.reroutes?[alert]?.reroutedTo ?? ""]?.short1 ?? "")**")
                                                .padding(.horizontal,4)
                                        }
                                        .padding(.leading,5)
                                        Spacer()
                                    }
                                }
                                .frame(width: geometry.size.width-20,height: 60)
                            } else {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 10)
                                        .foregroundColor(Color("cLessDarkGray"))
                                        .shadow(radius: 2)
                                    HStack {
                                        Image(systemName: "point.topleft.down.curvedto.point.filled.bottomright.up")
                                            .padding(2)
                                            .padding(.leading,15)
                                            .font(.system(size: 30))
                                        VStack(alignment: .leading, spacing: 0) {
                                            HStack(spacing: 0) {
                                                Text("Certain trains running via")
                                                    .padding(4)
                                                Image(alerts.northbound.reroutes?[alert]?.via ?? "")
                                                    .resizable()
                                                    .frame(width: 16, height: 16)
                                            }
                                            Text("from **\(stationsDict[alerts.northbound.reroutes?[alert]?.reroutedFrom ?? ""]?.short1 ?? "")** to **\(stationsDict[alerts.northbound.reroutes?[alert]?.reroutedTo ?? ""]?.short1 ?? "")**")
                                                .padding(.horizontal,4)
                                        }
                                        .padding(.leading,5)

                                        Spacer()
                                    }
                                }
                                .frame(width: geometry.size.width-20,height: 60)
                            }
                        }
//                        HStack {
//                            Text("Other:")
//                                .padding(.horizontal)
//                            Spacer()
//                        }
                        ForEach(getLocalStationKeys(alerts.northbound.localStations ?? [String: Line_ServiceDisruption_Local]()), id: \.self) { alert in
                            if alerts.northbound.localStations?[alert]?.occurances ?? 0 > 2 {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 10)
                                        .foregroundColor(Color("cLessDarkGray"))
                                        .shadow(radius: 2)
                                    HStack {
                                        Image(systemName: "tortoise.fill")
                                            .padding(2)
                                            .padding(.leading,5)
                                            .font(.system(size: 30))
                                            .foregroundColor(.green)
                                        VStack(alignment: .leading) {
                                            Text("**Running Local** in: \(formattedLocalBoros(stations: alerts.northbound.localStations?[alert]?.stations ?? []))")
                                            Text("Stopping at: \(getAllStations(stations: alerts.northbound.localStations?[alert]?.stations ?? []))")
                                        }
                                        Spacer()
                                    }
                                }
                                .frame(width: geometry.size.width-20,height: 100)
                            }
                        }
                        ForEach(getSkippedStationKeys(alerts.northbound.skippedStations ?? [String: Line_ServiceDisruption_Skipped]()), id: \.self) { alert in
                            if alerts.northbound.skippedStations?[alert]?.occurances ?? 0 > 2 {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 10)
                                        .foregroundColor(Color("cLessDarkGray"))
                                        .shadow(radius: 2)
                                    HStack {
                                        Image(systemName: "hare.fill")
                                            .padding(2)
                                            .padding(.leading,5)
                                            .font(.system(size: 30))
                                        VStack(alignment: .leading) {
                                            Text(String(format: NSLocalizedString("skipping-stations", comment: ""), getAllStations(stations: alerts.northbound.skippedStations?[alert]?.stations ?? [])))
//                                            Text("**Skipping**: \()")
                                        }
                                        Spacer()
                                    }
                                }
                                .frame(width: geometry.size.width-20,height: 80)
                            }
                        }
                    } else {
                        ForEach(getDelayKeys(alerts.southbound.delays ?? [String: Line_ServiceDisruption_Delay]()), id: \.self) { alert in
                            if alerts.southbound.delays?[alert]?.delayAmmount ?? 0 > 120 {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 10)
                                        .foregroundColor(Color("cLessDarkGray"))
                                        .shadow(radius: 2)
                                    HStack {
                                        Image(systemName: "clock.badge.exclamationmark.fill")
                                            .foregroundStyle(.yellow, Color("whiteblack"))
                                            .padding(2)
                                            .padding(.leading,10)
                                            .font(.system(size: 30))
                                        

                                        VStack(alignment: .leading) {
                                            HStack(spacing: 0) {
                                                Image(line)
                                                    .resizable()
                                                    .frame(width: 16, height: 16)
                                                    .padding(.leading, 5)
                                                Text("train to \(stationsDict[alerts.southbound.delays?[alert]?.destination ?? ""]?.short1 ?? "") has been stalled")
                                                    .padding(4)
                                            }
                                            Text("at \(stationsDict[alerts.southbound.delays?[alert]?.location ?? ""]?.short1 ?? "") for \((alerts.southbound.delays?[alert]?.delayAmmount ?? 0)/60) minutes.")
                                                .padding(.top,-10)
                                                .padding(.leading, 5)
                                        }
                                        .padding(.leading, 6)
                                        Spacer()
                                    }
                                }
                                .frame(width: geometry.size.width-20,height: 60)
                            }
                        }

                        ForEach(getSuspensionKeys(alerts.southbound.suspended ?? [String: Line_ServiceDisruption_Suspended]()), id: \.self) { alert in
                            if alerts.southbound.suspended?[alert]?.occurances ?? 0 > 2 {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 10)
                                        .foregroundColor(Color("cLessDarkGray"))
                                        .shadow(radius: 2)
                                    HStack {
                                        Image(systemName: "xmark.octagon.fill")
                                            .foregroundStyle(.white, .red)
                                            .padding(2)
                                            .padding(.leading,10)
                                            .font(.system(size: 30))
                                        

                                        VStack(alignment: .leading) {
                                            Text("**Not Running** from **\(stationsDict[alerts.southbound.suspended?[alert]?.stations[0] ?? ""]?.short1 ?? "")** to **\(stationsDict[alerts.southbound.suspended?[alert]?.stations[1] ?? ""]?.short1 ?? "")**")
                                        }
                                        .padding(.leading, 6)
                                        Spacer()
                                    }
                                }
                                .frame(width: geometry.size.width-20,height: 60)
                            }
                        }
                        ForEach(getRerouteKeys(alerts.southbound.reroutes ?? [String: Line_ServiceDisruption_Reroutes]()), id: \.self) { alert in
                            if alerts.southbound.reroutes?[alert]?.occurances ?? 0 > 2 {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 10)
                                        .foregroundColor(Color("cLessDarkGray"))
                                        .shadow(radius: 2)
                                    HStack {
                                        Image(systemName: "point.topleft.down.curvedto.point.filled.bottomright.up")
                                            .padding(2)
                                            .padding(.leading,15)
                                            .font(.system(size: 30))
                                        VStack(alignment: .leading, spacing: 0) {
                                            HStack(spacing: 0) {
                                                Text("Running via")
                                                    .padding(4)
                                                Image(alerts.southbound.reroutes?[alert]?.via ?? "")
                                                    .resizable()
                                                    .frame(width: 16, height: 16)
                                            }
                                            Text("from **\(stationsDict[alerts.southbound.reroutes?[alert]?.reroutedFrom ?? ""]?.short1 ?? "")** to **\(stationsDict[alerts.southbound.reroutes?[alert]?.reroutedTo ?? ""]?.short1 ?? "")**")
                                                .padding(.horizontal,4)
                                        }
                                        .padding(.leading,5)
                                        Spacer()
                                    }
                                }
                                .frame(width: geometry.size.width-20,height: 60)
                            } else {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 10)
                                        .foregroundColor(Color("cLessDarkGray"))
                                        .shadow(radius: 2)
                                    HStack {
                                        Image(systemName: "point.topleft.down.curvedto.point.filled.bottomright.up")
                                            .padding(2)
                                            .padding(.leading,15)
                                            .font(.system(size: 30))
                                        VStack(alignment: .leading, spacing: 0) {
                                            HStack(spacing: 0) {
                                                Text("Certain trains running via")
                                                    .padding(4)
                                                Image(alerts.southbound.reroutes?[alert]?.via ?? "")
                                                    .resizable()
                                                    .frame(width: 16, height: 16)
                                            }
                                            Text("from **\(stationsDict[alerts.southbound.reroutes?[alert]?.reroutedFrom ?? ""]?.short1 ?? "")** to **\(stationsDict[alerts.southbound.reroutes?[alert]?.reroutedTo ?? ""]?.short1 ?? "")**")
                                                .padding(.horizontal,4)
                                        }
                                        .padding(.leading,5)

                                        Spacer()
                                    }
                                }
                                .frame(width: geometry.size.width-20,height: 60)
                            }
                        }

                        ForEach(getLocalStationKeys(alerts.southbound.localStations ?? [String: Line_ServiceDisruption_Local]()), id: \.self) { alert in
                            if alerts.southbound.localStations?[alert]?.occurances ?? 0 > 2 {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 10)
                                        .foregroundColor(Color("cLessDarkGray"))
                                        .shadow(radius: 2)
                                    HStack {
                                        Image(systemName: "tortoise.fill")
                                            .padding(2)
                                            .padding(.leading,5)
                                            .font(.system(size: 30))
                                            .foregroundColor(.green)
                                        VStack(alignment: .leading) {
                                            Text("**Running Local** in: \(formattedLocalBoros(stations: alerts.southbound.localStations?[alert]?.stations ?? []))")
                                            Text("Stopping at: \(getAllStations(stations: alerts.southbound.localStations?[alert]?.stations ?? []))")
                                        }
                                        Spacer()
                                    }
                                }
                                .frame(width: geometry.size.width-20,height: 100)
                            }
                        }
                        ForEach(getSkippedStationKeys(alerts.southbound.skippedStations ?? [String: Line_ServiceDisruption_Skipped]()), id: \.self) { alert in
                            if alerts.southbound.skippedStations?[alert]?.occurances ?? 0 > 2 {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 10)
                                        .foregroundColor(Color("cLessDarkGray"))
                                        .shadow(radius: 2)
                                    HStack {
                                        Image(systemName: "hare.fill")
                                            .padding(2)
                                            .padding(.leading,5)
                                            .font(.system(size: 30))
                                        VStack(alignment: .leading) {
                                            Text("**Skipping**: \(getAllStations(stations: alerts.southbound.skippedStations?[alert]?.stations ?? []))")
                                        }
                                        Spacer()
                                    }
                                }
                                .frame(width: geometry.size.width-20,height: 80)
                            }
                        }
                    }
                }
                
            }
            VStack {
                ZStack {
                    VStack {
                        Rectangle()
                            .foregroundColor(Color("cDarkGray"))
                            .shadow(radius: 2)
                        Spacer()
                    }
                    // MARK: - Line portion stuff
                    VStack(spacing: 0) {
                        Spacer()
                        Capsule()
                            .fill(Color("second"))
                            .frame(width: 34, height: 4.5)
                            .padding(.top, -10)
                            .onAppear {
                                apiCall().getServiceDisruption(line: line) { (alert) in
                                    self.alerts = alert
                                }
                            }
                        
                        HStack {
                            Image(line)
                                .resizable()
                                .frame(width: 50, height: 50)
                                .shadow(radius: 2)
                                .padding()
                            HStack {
                                Button {
                                    direction = "north"
                                } label: {
                                    ZStack {
                                        if direction == "north" {
                                            RoundedRectangle(cornerRadius: 10)
                                                .foregroundColor(Color("cLessDarkGray"))
                                                .frame(width: textSize.width + 25, height: 40)
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 13)
                                                        .stroke(.blue,lineWidth: 2)
                                                        .frame(width: textSize.width + 33, height: 48)
                                                )
                                                .shadow(radius: 2)
                                        } else {
                                            RoundedRectangle(cornerRadius: 10)
                                                .foregroundColor(Color("cLessDarkGray"))
                                                .frame(width: textSize.width + 25, height: 40)
                                                .shadow(radius: 2)
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 12)
                                                        .stroke(Color("cDarkGray"),lineWidth: 2)
                                                        .frame(width: textSize.width + 33, height: 48)
                                                )
                                            
                                        }
                                        Text("Northbound")
                                            .foregroundColor(Color("whiteblack"))
                                            .readSize { size in
                                                textSize = size
                                            }
                                    }
                                }
                                .buttonStyle(CButton())
                                Spacer().frame(width: 15)
                                Button {
                                    direction = "south"
                                } label: {
                                    ZStack {
                                        if direction == "south" {
                                            RoundedRectangle(cornerRadius: 10)
                                                .foregroundColor(Color("cLessDarkGray"))
                                                .frame(width: textSize.width + 25, height: 40)
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 13)
                                                        .stroke(.blue,lineWidth: 2)
                                                        .frame(width: textSize.width + 33, height: 48)
                                                )
                                                .shadow(radius: 2)
                                        } else {
                                            RoundedRectangle(cornerRadius: 10)
                                                .foregroundColor(Color("cLessDarkGray"))
                                                .frame(width: textSize.width + 25, height: 40)
                                                .shadow(radius: 2)
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 12)
                                                        .stroke(Color("cDarkGray"),lineWidth: 2)
                                                        .frame(width: textSize.width + 33, height: 48)
                                                )
                                            
                                        }
                                        Text("Southbound")
                                            .foregroundColor(Color("whiteblack"))
                                            .readSize { size in
                                                textSize = size
                                            }
                                    }
                                }
                                .buttonStyle(CButton())
                            }
                            Spacer()
                        }
                        Spacer()
                    }
                    Spacer()
                }
                .frame(height: 120)
                Spacer()
            }
        }
    }
    }
}

struct ServiceAlertsView_Previews: PreviewProvider {
    static var previews: some View {
        serviceAlertsView(line: "A", direction: "north")
    }
}
