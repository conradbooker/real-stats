//
//  StationView.swift
//  real-stats
//
//  Created by Conrad on 3/13/23.
//

import SwiftUI
import WrappingHStack

func getSortedTimes(direction: [String: NewStationTime]?) -> [String] {
    var arr = [String]()
    for time in direction!.keys {
        arr.append(time)
    }
    arr = arr.sorted()
    return Array(arr.prefix(3))
}


struct StationView: View {
//    @FetchRequest private var favoriteStations: FetchedResults<FavoriteStation>
    let persistentContainer = CoreDataManager.shared.persistentContainer
    
    @ObservedObject var monitor = Network()
    @FetchRequest(entity: FavoriteStation.entity(), sortDescriptors: [NSSortDescriptor(key: "dateCreated", ascending: false)]) private var favoriteStations: FetchedResults<FavoriteStation>

    @Environment(\.managedObjectContext) private var viewContext
//    @Environment(\.dismiss) var dismiss
    let persistedContainer = CoreDataManager.shared.persistentContainer
    
    var complex: Complex
    @State var chosenStation: Int
    
//    @State private var isFavorited: Bool
    
    private func getWidth(_ items: Int) -> CGFloat {
        return CGFloat((items*30)+15)
    }
    
    @State var times: NewTimes = load("608.json")
    @State var trips: [String: Trip] = load("stopTimes.json")
    
    @State var tripKeys: [String] = []
    
    @State var short1Size = CGSize()
    @State var short2Size = CGSize()
    @State var lineSelectorSize = CGSize()
    
    @State var isFavorited: Bool
    
    init(complex: Complex, chosenStation: Int, isFavorited: Bool) {
        self.complex = complex
        self._chosenStation = State(initialValue: chosenStation)
        self._isFavorited = State(initialValue: isFavorited)
        
    }
    
    /*
     for station in fetchrequests favorites, if favorites.chosen id == complex.id, isfavorited = false
     */
    
    func deleteFavorite() {
        for favoriteStation in favoriteStations {
            if favoriteStation.complexID == complex.id && favoriteStation.chosenStationNumber == chosenStation {
                viewContext.delete(favoriteStation)
                do {
                    try viewContext.save()
                } catch {
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    func addFavorite() {
        let favoriteStation = FavoriteStation(context: viewContext)
        favoriteStation.complexID = Int16(complex.id)
        favoriteStation.chosenStationNumber = Int16(chosenStation)
        favoriteStation.dateCreated = Date()
        do {
            try viewContext.save()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // MARK: - Main Content
                Color("cDarkGray")
                    .ignoresSafeArea()
                ScrollView {
                    VStack(alignment: .leading) {
                        Spacer().frame(height:lineSelectorSize.height + short1Size.height + short2Size.height + 40)
                            .onAppear {
                                print(chosenStation)
                            }
                        
                        // MARK: - No Wifi
                        
                        if hasNetwork() {
                            Text("No Wifi: real-stats will downloaded data")
                                .padding()
                        }
                        if times.service {
                            // MARK: - North Times
                            if (Array(times.north!.keys).sorted().count < 1) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 10)
                                        .foregroundColor(Color("cLessDarkGray"))
                                        .shadow(radius: 2)
                                        .frame(height: 100)
                                        .padding()
                                    HStack {
                                        Image(systemName: "exclamationmark.triangle.fill")
                                            .foregroundStyle(.black, .yellow)
                                            .font(.system(size: 60))
                                            .shadow(radius: 2)
                                        .padding()
                                        Text("No service to \(complex.stations[chosenStation].northDir) at this station")
                                            .font(.headline)
                                            .fontWeight(.semibold)
                                            .padding(5)
                                            .frame(width: geometry.size.width / 2)
                                    }
                                }
                                .padding(.bottom,-20)
                            } else {
                                Text(complex.stations[chosenStation].northDir)
                                    .font(.title3)
                                    .padding(.horizontal)
                                    .padding(.top,2)
                                ForEach(Array(times.north!.keys).sorted(), id: \.self) { line in
                                    StationTimeRow(
                                        line: line,
                                        direction: "N",
                                        trainTimes: times,
                                        times: getSortedTimes(direction: times.north![line]!!),
                                        trips: trips
                                    )
                                    .environment(\.managedObjectContext, persistentContainer.viewContext)
                                    .padding(.horizontal,5)
                                    .frame(height: 55)
                                }
                            }
                            // MARK: - South Times
                            if (Array(times.south!.keys).sorted().count < 1) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 10)
                                        .foregroundColor(Color("cLessDarkGray"))
                                        .shadow(radius: 2)
                                        .frame(height: 100)
                                        .padding()
                                    HStack {
                                        Image(systemName: "exclamationmark.triangle.fill")
                                            .foregroundStyle(.black, .yellow)
                                            .font(.system(size: 60))
                                            .shadow(radius: 2)
                                        .padding()
                                        Text("No service to \(complex.stations[chosenStation].southDir) at this station")
                                            .font(.headline)
                                            .fontWeight(.semibold)
                                            .padding(5)
                                            .frame(width: geometry.size.width / 2)
                                    }
                                }
                                .padding(.bottom,-20)
                            } else {
                                Divider()
                                    .padding(.top)
                                Text(complex.stations[chosenStation].southDir)
                                    .font(.title3)
                                    .padding(.horizontal)
                                ForEach(Array(times.south!.keys).sorted(), id: \.self) { line in
                                    StationTimeRow(
                                        line: line,
                                        direction: "S",
                                        trainTimes: times,
                                        times: getSortedTimes(direction: times.south![line]!!),
                                        trips: trips
                                    )
                                    .environment(\.managedObjectContext, persistentContainer.viewContext)
                                    .padding(.horizontal,5)
                                    .frame(height: 55)
                                }
                            }
                        } else {
                            ZStack {
                                RoundedRectangle(cornerRadius: 10)
                                    .foregroundColor(Color("cLessDarkGray"))
                                    .shadow(radius: 2)
                                    .frame(height: 100)
                                    .padding()
                                HStack {
                                    Image(systemName: "exclamationmark.triangle.fill")
                                        .foregroundStyle(.black, .yellow)
                                        .font(.system(size: 60))
                                        .shadow(radius: 2)
                                    .padding()
                                    Text("No service at this station ☹️")
                                        .font(.headline)
                                        .fontWeight(.semibold)
                                        .padding(.leading, -5)
                                }
                            }
                        }
                        Spacer()
                            .frame(height: 200)
                    }
                }
                // MARK: - Top Part
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
                                apiCall().getStationAndTrips(station: complex.stations[chosenStation].GTFSID) { (stationAndTrip) in
                                    self.times = stationAndTrip.station
                                    self.trips = stationAndTrip.trips
//                                    print(stationAndTrip)
                                }

//                                apiCall().getStationTimes(station: complex.stations[chosenStation].GTFSID) { (times) in
//                                    self.times = times
//                                }
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
                            
                            // MARK: - ADA Button
                            
                            Button {
                                
                            } label: {
                                if complex.stations[chosenStation].ADA > 0 {
                                    Image("ADA")
                                        .resizable()
                                        .frame(width: 30, height: 30)
                                }
                            }
                            .buttonStyle(CButton())
                            .shadow(radius: 2)
                            
                            // MARK: - Favorite Button
                            Button {
                                if isFavorited {
                                    withAnimation(.linear(duration: 0.1)) {
                                        isFavorited = false
                                    }
                                    deleteFavorite()
//                                    delete
                                } else {
                                    withAnimation(.linear(duration: 0.1)) {
                                        isFavorited = true
                                    }
                                    addFavorite()
//                                    add new instance of favorites
                                }
                            } label: {
                                Image(systemName: isFavorited ? "star.fill" : "star")
                                    .resizable()
                                    .foregroundColor(isFavorited ? .yellow : Color("whiteblack"))
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
                                
                                apiCall().getStationAndTrips(station: complex.stations[chosenStation].GTFSID) { (stationAndTrip) in
                                    withAnimation(.spring(response: 0.31, dampingFraction: 1-0.26)) {
                                        self.times = stationAndTrip.station
                                        self.trips = stationAndTrip.trips
                                        //                                    print(stationAndTrip)
                                    }
                                }
                                if isFavorited {
                                    for favoriteStation in favoriteStations {
                                        if favoriteStation.complexID == complex.id {
                                            favoriteStation.chosenStationNumber = Int16(chosenStation)
                                            favoriteStation.dateCreated = Date()
                                            do {
                                                try viewContext.save()
                                            } catch {
                                                print(error.localizedDescription)
                                            }
                                            break
                                        }
                                    }
                                    
                                }
//                                if station in favorites, favorited == true
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
                                                        .frame(width: getWidth(complex.stations[index].weekdayLines.count) + 8, height: 48)
                                                )
                                                .shadow(radius: 2)
                                        } else {
                                            RoundedRectangle(cornerRadius: 10)
                                                .foregroundColor(Color("cLessDarkGray"))
                                                .frame(width: getWidth(complex.stations[index].weekdayLines.count), height: 40)
                                                .shadow(radius: 2)
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 12)
                                                        .stroke(Color("cDarkGray"),lineWidth: 2)
                                                        .frame(width: getWidth(complex.stations[index].weekdayLines.count) + 8, height: 48)
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
        StationView(complex: complexData[423], chosenStation: 0, isFavorited: false)
            .environment(\.managedObjectContext, persistedContainer.viewContext)
    }
}
