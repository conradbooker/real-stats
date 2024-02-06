//
//  BusRow.swift
//  Service Bandage
//
//  Created by Conrad on 1/12/24.
//

import SwiftUI

struct BusTripItem: Identifiable {
    var id = UUID()
    var tripID: String
}


struct BusRow: View {
    var line: String
    var destination: String
    var time: Int
    var tripID: String
    
    @State private var busTripItem: BusTripItem?
    
    var routeColor: [Color] {
        return getCorrectColor(route: line)
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
        Button {
            busTripItem = BusTripItem(tripID: tripID)
        } label: {
            ZStack {
                Color.clear
                    .background(.ultraThinMaterial)
                    .cornerRadius(10)
                    .shadow(radius: 2)
                HStack {
                    Text(line_cleaned)
                        .padding(2)
                        .foregroundColor(routeColor[0])
                        .background(
                            routeColor[1]
                                .background(.ultraThinMaterial)
                                .cornerRadius(4)
//                                .shadow(radius: 2)
                            
                        )
                        .padding(.leading,5)
                    
                    Text(busData_dictionary[destination]?.name ?? "Unknown")
                    Spacer()
                    individualTime_bus(time: time)
                        .padding(.trailing,8)
                }
            }
            .frame(height: 35)
            
        }
        .buttonStyle(CButton())
        .sheet(item: $busTripItem) { item in
            BusTripView(tripID: item.tripID)
        }
    }
}

struct individualTime_bus: View {
    var currentTime: Int = Int(NSDate().timeIntervalSince1970)
    var time: Int
    var body: some View {
        VStack(spacing: -5) {
            if time-currentTime >= 70 {
                Text("\(Int(time-currentTime-10)/60)")
                    .font(.title3)
                    .fontWeight(.bold)
                if Int(time-currentTime-10)/60 == 1 {
                    Text("min")
                        .font(.footnote)
                } else {
                    Text("mins")
                        .font(.footnote)
                }
            } else if time-currentTime > 69 {
                Text("<1")
                    .font(.title2)
                    .fontWeight(.bold)
                Text("min")
                    .font(.footnote)
            } else if time-currentTime > 20 {
                Text("due")
            } else if time-currentTime > 0 {
                Text("here")
            } else {
                Text("left")
            }
        }
    }
}


struct BusRow_Previews: PreviewProvider {
    static var previews: some View {
        BusRow(line: "M101", destination: "Amsterdam Av / 193 St", time: 1705800000, tripID: "hi")
    }
}
