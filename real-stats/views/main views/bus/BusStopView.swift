//
//  BusStop.swift
//  Service Bandage
//
//  Created by Conrad on 1/12/24.
//

import SwiftUI

struct BusStopView: View {
    var stopID: String
    @State var refreshButtonRotation: Double = 0.0
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // MARK: - Main Content
                Color("cDarkGray")
                    .ignoresSafeArea()
                ScrollView {
                    VStack(alignment: .leading) {
                        Spacer().frame(height: 40)
                        Text("main content area")
                    }
                }
                // MARK: - Top Part
                ZStack {
                    VStack {
                        Rectangle()
                            .frame(width: geometry.size.width, height: 100)
                            .foregroundColor(Color("cDarkGray"))
                            .shadow(radius: 2)
                        Spacer()
                    }
                    VStack(spacing: 0) {
                        Capsule()
                            .fill(Color("second"))
                            .frame(width: 34, height: 4.5)
                            .padding(.top, 6)
                            .onAppear {
//                                MARK: - API CALL FOR BUS
//                                apiCall().getStationAndTrips(station: complex.stations[chosenStation].GTFSID) { (stationAndTrip) in
//                                    self.times = stationAndTrip.station
//                                    self.trips = stationAndTrip.trips
//                                }
                            }
                        HStack {
                            VStack(alignment: .leading) {
                                Text(busData_dictionary[stopID]?.short2 ?? "")
                                    .font(.largeTitle)
                                    .fontWeight(.bold)
                                Text(busData_dictionary[stopID]?.short1 ?? "")
                                    .font(.title2)
                                    .fontWeight(.bold)
                            }
                            .padding(.leading)
                            .padding(.vertical, 10)
                            Spacer()
                            
                            // MARK: - ADA Button
                            
                            Image("ADA")
                                .resizable()
                                .frame(width: 30, height: 30)
                                .shadow(radius: 2)
                        }
                        
                        // MARK: - Station Selector
                        Button {
                            withAnimation(.spring(response: 0.31, dampingFraction: 1-0.26)) {
//                                chosenStation = index
                                refreshButtonRotation += 360
                            }
                            
//                                MARK: - BUS REFRESH
//                                apiCall().getStationAndTrips(station: complex.stations[chosenStation].GTFSID) { (stationAndTrip) in
//                                    withAnimation(.spring(response: 0.31, dampingFraction: 1-0.26)) {
//                                        self.times = stationAndTrip.station
//                                        self.trips = stationAndTrip.trips
//                                        //                                    print(stationAndTrip)
//                                    }
//                                }
                        } label: {
                            VStack {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 10)
                                        .foregroundColor(Color("cLessDarkGray"))
                                        .frame(width: 40 + 30, height: 40)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 13)
                                                .stroke(.blue,lineWidth: 2)
                                                .frame(width: 40 + 38, height: 48)
                                        )
                                        .shadow(radius: 2)
                                    HStack(spacing: 2.5) {
                                        Image(systemName: "arrow.clockwise")
                                            .frame(width: 30, height: 30)
                                            .rotationEffect(.degrees(refreshButtonRotation))
                                    }
                                }
                            }
                        }
                        .padding([.leading,.bottom])
                        .buttonStyle(CButton())
                        Spacer()
                    }
                }
            }
        }
    }
}

struct BusStopView_Previews: PreviewProvider {
    static var previews: some View {
        BusStopView(stopID: "401898")
    }
}
