//
//  BusTrip_Stop.swift
//  Service Bandage
//
//  Created by Conrad on 2/4/24.
//

import SwiftUI

struct LineShape_Bus: View {
    var trip: BusTrip
    var station: String
    var line: String
    var counter: Int
    
    var imageSize: CGFloat = 22
    
    var body: some View {
        VStack {
            Group {
                ZStack {
                    Circle()
                        .foregroundColor(Color("cDarkGray"))
                        .frame(width: imageSize-0.3, height: imageSize-0.3)
                    Circle()
                        .strokeBorder(Color("cDarkGray"),lineWidth: 3)
                        .background(
                            Circle()
                                .foregroundColor(getLineColor_Bus(line: line, time: trip.stations[station]?.times[0] ?? 0))
                                .frame(width: imageSize-1, height: imageSize-1)
                        )
                    .frame(width: imageSize, height: imageSize)
                }
            }
            .padding(.vertical,1)
            Spacer()
        }
        .padding(.horizontal, 15)
    }
}


struct BusTrip_Stop: View {
    var station: String
    var line: String
    var trip: BusTrip
    var counter: Int
    
    var body: some View {
        HStack(spacing: 0) {
            ZStack {
                LineShape_Bus(trip: trip, station: station, line: line, counter: counter)
                VStack {
                    if getCurrentStationClean_Bus(stations: trip.stations) == station {
                        withAnimation(.spring(response: 0.4)) {
                            BusDot(line: line)
                                .frame(height: 30)
                        }
                        Spacer()
                    } else if getStationBefore_Bus(stations: trip.stations) == station {
                        Spacer()
                            .frame(height: 20)
                        withAnimation(.spring(response: 0.4)) {
                            BusDot(line: line)
                                .frame(height: 50)
                        }
                        Spacer()
                    }

                }
            }
            Group {
                VStack(alignment: .leading, spacing: 0) {
                    Text(busData_dictionary[station]?.short2 ?? "")
//                    if (busData_dictionary[station]?.short2 ?? "") != "" {
                        Text(busData_dictionary[station]?.short1 ?? "")
                            .font(.subheadline)
//                    }
//                    HStack(spacing: 1.5) {
//                        ForEach(stationsDict[station]?.weekdayLines ?? [""], id: \.self) { bullet in
//                            if bullet != trip.line ?? "" {
//                                Image(bullet)
//                                    .resizable()
//                                    .frame(width: 16, height: 16)
//                            }
//                        }
//                    }
                    Spacer()
                }

                Spacer()
                VStack(alignment: .trailing, spacing: 0) {
                    FormattedTime(time: trip.stations[station]?.times[0] ?? 0, counter: counter)
                    Text(Date(timeIntervalSince1970: TimeInterval(trip.stations[station]?.times[0] ?? 0)), style: .time)
                    Spacer()
                }
                .padding(.trailing)
            }
            .opacity(getOpacity(time: trip.stations[station]?.times[0] ?? 0))

        }
    }
}



struct BusTrip_Stop_Previews: PreviewProvider {
    static var previews: some View {
        BusTrip_Stop(station: "401898", line: "M86+", trip: defaultBusTrip, counter: 15)
    }
}
