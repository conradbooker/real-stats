//
//  Home.swift
//  real-stats
//
//  Created by Conrad on 3/20/23.
//

import SwiftUI

struct Home: View {
    @State private var search: String = ""
    var stations: [String] = ["96 St","86 St","42 St-Grand Central","Jamaica Center","Myrtle Ave","Court Sq-23 St"]
    
    var body: some View {
        VStack(spacing: 0) {
            Capsule()
                .fill(Color("second"))
                .frame(width: 34, height: 4.5)
                .padding(.top, 6)
                .shadow(radius: 2)
            
            // MARK: Search
            HStack(spacing: 0) {
                TextField("Search for a station or a train", text: $search)
                    .textFieldStyle(.roundedBorder)
                    .padding(12.0)
                Image(systemName: "gear.circle.fill")
                    .font(.title)
                    .foregroundColor(.gray)
                    .shadow(radius: 2)
                    .padding([.top, .bottom, .trailing], 12.0)
            }
            
            // MARK: Favorites
            HStack {
                Text("Favorites")
                    .padding(.horizontal, 12)
                Spacer()
            }
            ScrollView(.horizontal) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .frame(height: 112)
                        .padding(.leading,6)
                    HStack {
                        ForEach(stations, id: \.self) { station in
                            FavoriteBox(stationName: station)
                                .frame(width: 140,height: 100)
                                .background(Color("second"))
                                .clipShape(RoundedRectangle(cornerRadius: 5))
                        }
                    }
                    .padding(.leading,12)
                }
            }
            .padding(.vertical, 12.0)
            
            // MARK: Nearby
            HStack {
                Text("Nearby")
                    .padding(.horizontal, 12)
                Spacer()
            }
            ScrollView(.horizontal) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .frame(height: 112)
                        .padding(.leading,6)
                    HStack {
                        ForEach(stations, id: \.self) { station in
                            FavoriteBox(stationName: station)
                                .frame(width: 140,height: 100)
                                .background(Color("second"))
                                .clipShape(RoundedRectangle(cornerRadius: 5))
                        }
                    }
                    .padding(.leading,12)
                }
            }
            .padding(.vertical, 12.0)

        }
    }
}

struct Home_Previews: PreviewProvider {
    static var previews: some View {
        Home()
    }
}
