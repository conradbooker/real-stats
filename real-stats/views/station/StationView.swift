//
//  StationView.swift
//  real-stats
//
//  Created by Conrad on 3/13/23.
//

import SwiftUI
import WrappingHStack

var defaultTimes: String = """
{
   "north": [],
   "south": []
}
"""

struct StationView: View {
//    @FetchRequest private var favoriteStations: FetchedResults<FavoriteStation>
    @FetchRequest(entity: FavoriteStation.entity(), sortDescriptors: [NSSortDescriptor(key: "dateCreated", ascending: false)]) private var favoriteStations: FetchedResults<FavoriteStation>

    @Environment(\.managedObjectContext) private var viewContext
    let persistedContainer = CoreDataManager.shared.persistentContainer
    
    var complex: Complex
    @State var chosenStation: Int
    
//    @State private var isFavorited: Bool
    
    private func getWidth(_ items: Int) -> CGFloat {
        return CGFloat((items*30)+15)
    }
    
    @State var times: Time = defaultTimes.decodeJson(Time.self)
    
    @State var short1Size = CGSize()
    @State var short2Size = CGSize()
    @State var lineSelectorSize = CGSize()

//    init(complex: Complex, chosenStation: Int) {
//        /*
//         for station in fetchrequests favorites, if favorites.chosen id == complex.id, isfavorited = false
//         */
////        self.favoriteStations = favoriteStations
//        self.complex = complex
//        self.chosenStation = chosenStation
//        self.times =
//    }
    
    
        
//    init(complex: Complex, chosenStation: Int) {
//        self.complex = complex
//        self.chosenStation = chosenStation
//        self.times = (String(returnTimes(station: complex.stations[chosenStation].GTFSID, trunkLine: complex.stations[chosenStation].trunk, expectedLines: complex.stations[chosenStation].possibleLines)) ?? "").decodeJson([Time].self)
//    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // MARK: - Main Content
                ScrollView {
                    VStack(alignment: .leading) {
                        Spacer().frame(height:lineSelectorSize.height + short1Size.height + short2Size.height + 40)
                        
                        // MARK: - North
                        Text(complex.stations[chosenStation].northDir)
                            .padding(.horizontal)
                        ForEach(times.north, id: \.self) { line in
                            LineRow(
                                line: line.line,
                                destination: stationKeys[String((line.times[0].destinationID).dropLast(1))] ?? line.times[0].destinationID,
                                times: line.times,
                                disruptions: .none
                            )
                            .frame(height: 65)
                        }
                        // MARK: - South
                        Text(complex.stations[chosenStation].southDir)
                            .padding(.horizontal)
                        ForEach(times.south, id: \.self) { line in
                            LineRow(
                                line: line.line,
                                destination: stationKeys[String((line.times[0].destinationID).dropLast(1))] ?? line.times[0].destinationID,
                                times: line.times,
                                disruptions: .none
                            )
                            .frame(height: 65)
                        }
                    }
                }
                ZStack {
                    VStack {
                        Rectangle()
                            .frame(width: geometry.size.width, height: lineSelectorSize.height + short1Size.height + short2Size.height + 30)
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
                                times = (String(returnTimes(station: complex.stations[chosenStation])) ?? "").decodeJson(Time.self)
                            }
                        HStack {
                            VStack(alignment: .leading) {
                                Text(complex.stations[chosenStation].short1)
                                    .font(.largeTitle)
                                    .fontWeight(.bold)
                                    .readSize { size in
                                        short1Size = size
                                    }
                                Text(complex.stations[chosenStation].short2)
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .readSize { size in
                                        short2Size = size
                                    }
                            }
                            .padding(.leading)
                            .padding(.vertical, 10)
                            Spacer()
                            // MARK: - Favorite Button
                            Button {
                                
                            } label: {
                                Image(systemName: "star.fill")
                                    .resizable()
                                    .foregroundColor(Color.yellow)
                                    .frame(width: 30, height: 30)
                                    .padding(.trailing)
                                    .shadow(radius: 2)
                            }
                            .buttonStyle(CButton())
                        }
                        
                        // MARK: - Station Selector
                        WrappingHStack(0..<complex.stations.count, id: \.self,spacing: .constant(0)) { index in
                            Button {
                                chosenStation = index
                                times = (String(returnTimes(station: complex.stations[chosenStation])) ?? "").decodeJson(Time.self)
                            } label: {
                                VStack {
                                    ZStack {
                                        if chosenStation == index {
                                            RoundedRectangle(cornerRadius: 10)
                                                .foregroundColor(Color("cLessDarkGray"))
                                                .frame(width: getWidth(complex.stations[index].weekdayLines.count), height: 40)
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 13)
                                                        .stroke(.blue,lineWidth: 2)
                                                        .frame(width: getWidth(complex.stations[index].weekdayLines.count) + 6, height: 46)
                                                )
                                                .shadow(radius: 2)
                                        } else {
                                            RoundedRectangle(cornerRadius: 10)
                                                .foregroundColor(Color("cLessDarkGray"))
                                                .frame(width: getWidth(complex.stations[index].weekdayLines.count), height: 40)
                                                .shadow(radius: 2)
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 12)
                                                        .stroke(.white,lineWidth: 2)
                                                        .frame(width: getWidth(complex.stations[index].weekdayLines.count) + 6, height: 46)
                                                )

                                        }
                                        HStack(spacing: 2.5) {
                                            ForEach(complex.stations[index].weekdayLines, id: \.self) { line in
                                                Image(line)
                                                    .resizable()
                                                    .frame(width: 30, height: 30)
                                            }
                                        }
                                    }
                                }
                            }
                            .padding([.leading,.bottom])
                            .buttonStyle(CButton())
                        }
                        .readSize { size in
                            lineSelectorSize = size
                        }
                        Spacer()
                    }
                }
            }
        }
    }
}

struct StationView_Previews: PreviewProvider {
    let randomInt = Int.random(in: 1..<5)
    static var previews: some View {
        let persistedContainer = CoreDataManager.shared.persistentContainer
        StationView(complex: complexData[423], chosenStation: 0)
            .environment(\.managedObjectContext, persistedContainer.viewContext)
    }
}
