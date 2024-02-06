//
//  BusSearchRow.swift
//  Service Bandage
//
//  Created by Conrad on 1/13/24.
//

import SwiftUI
import WrappingHStack

func getCorrectColor(route: String) -> [Color] {
    if busRouteData[route]?["type"] ?? "" == "sbs" {
        return [Color.white,Color("turqoise")]
    } else if busRouteData[route]?["type"] ?? "" == "regular" {
        return [Color.black,Color("yellow")]
    } else if busRouteData[route]?["type"] ?? "" == "express" {
        return [Color.white,Color("green")]
    } else if busRouteData[route]?["type"] ?? "" == "shuttle" {
        return [Color.black,Color.gray]
    } else if busRouteData[route]?["type"] ?? "" == "limited" {
        return [Color.white,Color("red")]
    }
        
    return [Color.black,Color("yellow")]
}


struct BusSearchRow: View {
    var stop_id: String
    
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        Button {
            
        } label: {
            ZStack {
                Color.clear
                    .background(.thickMaterial)
                    .environment(\.colorScheme,colorScheme)
                    .cornerRadius(10)
                    .shadow(radius: 2)
                    .frame(height: 60)
                HStack {
                    VStack(alignment: .leading) {
                        Text(String(busData_dictionary[stop_id]?.short1 ?? "Undefined") + " /")
                        Text(String(busData_dictionary[stop_id]?.short2 ?? "Undefined"))
                        //                    if busData_dictionary[stop_id]?.short2 ?? "Undefined" != "" {
                        //                        Text(busData_dictionary[stop_id]?.short2 ?? "Undefined")
                        //                            .font(.footnote)
                        //                    }
                        
                    }
                    .padding(.leading, 5)
                    Spacer()
//                    WrappingHStack(busData_dictionary[stop_id]?.lines ?? [String](), id: \.self, alignment: .trailing, spacing: .constant(0)) { line in
//                        Text(line)
//                            .padding(2)
//                            .font(.footnote)
//                            .foregroundColor(getCorrectColor(route: line)[0])
//                            .background(
//                                getCorrectColor(route: line)[1]
//                                //                                .padding()
//                                //                                .padding(.horizontal,5)
//                                    .background(.ultraThinMaterial)
//                                    .cornerRadius(3)
//                                    .shadow(radius: 2)
//                                
//                            )
//                            .padding(.trailing,4)
//                    }
//                    .padding()
//                    .frame(width: 200)
                }
            }
            .padding(6)
        }
        .buttonStyle(CButton())
    }
}

struct BusSearchRow_Previews: PreviewProvider {
    static var previews: some View {
        BusSearchRow(stop_id: "401093")
    }
}
