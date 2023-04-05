//
//  Home.swift
//  real-stats
//
//  Created by Conrad on 3/20/23.
//

import SwiftUI

func rand() -> Int {
    return Int.random(in: 1..<445)
}

struct Item: Identifiable {
    let id = UUID()
    let complex: Complex
}

struct Home: View {
    
    @Environment(\.managedObjectContext) private var viewContext
    let persistedContainer = CoreDataManager.shared.persistentContainer
    
    @State private var search: String = ""
    @State private var showStation: Bool = false
    @State private var complex: Complex = complexData[0]
    @State var selectedItem: Item?
    
    @State var fromFavorites: Bool = false
    @State var chosenStation: Int = 0
    
    @FetchRequest(entity: FavoriteStation.entity(), sortDescriptors: [NSSortDescriptor(key: "dateCreated", ascending: false)]) private var favoriteStations: FetchedResults<FavoriteStation>
    
//    private func getNearByStations(_ location: MK)
//    for station in stations, if station.location choser than station-1, set.add

    
    var favorites: [Complex] = [complexData[423],complexData[rand()],complexData[rand()],complexData[rand()],complexData[rand()],complexData[rand()]]
    var stations: [Complex] = [complexData[rand()],complexData[rand()],complexData[rand()],complexData[rand()],complexData[rand()],complexData[rand()]]

    @State var searchStations: [Complex] = []
    
    @FocusState var inputIsActive: Bool
    
    @StateObject var locationViewModel = LocationViewModel()
    
    func correctComplex(_ id: Int) -> Complex {
        for station in complexData {
            if station.id == id {
                return station
            }
        }
        return complexData[0]
    }
    
    func lookForNearbyStations() -> [Complex] {
        var closeComplexes = [Complex]()
        for num in 0..<6 {
            closeComplexes.append(complexData[num])
        }
        closeComplexes.append(complexData[0])
        var lowestComplex = closeComplexes[0]
        for complex in complexData {
            let currentLocation = locationViewModel.lastSeenLocation!.coordinate
            let complexDistance = abs(pow(pow(abs(currentLocation.longitude-complex.location.longitude), 2) + pow(abs(currentLocation.longitude-complex.location.longitude),2),(1/2)))
            
            for closeComplex in closeComplexes {
                find farthest away from currentLocation
            }
            if complexDistance > lowestComplexdistance, replace the two
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color("cDarkGray")
                    .ignoresSafeArea()
                VStack(spacing: 0) {
                    Capsule()
                        .fill(Color("second"))
                        .frame(width: 34, height: 4.5)
                        .padding(.top, 6)
                    
                    // MARK: - Search
                    
                    HStack {
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .foregroundColor(Color("cLessDarkGray"))
                                .shadow(radius: 2)
                                .frame(height: 40)
                            TextField("Search for a station or a train", text: $search)
                                .padding(.leading,6)
                                .focused($inputIsActive)
                                .onChange(of: search) { _ in
                                    if search.isEmpty {
                                        searchStations = []
                                    } else {
//                                        var set = Set<Complex>()
//                                        var filtered = complexData.filter { $0.complexName.localizedCaseInsensitiveContains(search)
//                                        }
//                                        for station in filtered {
//                                            set.insert(station)
//                                        }
                                        
                                        withAnimation(.spring(blendDuration: 0.25)) {
                                            searchStations = complexData.filter { $0.complexName.localizedCaseInsensitiveContains(search)
                                            }
                                        }
                                    }
                                }
                        }
                        if search != "" {
                            // Cancel
                            Button {
                                withAnimation(.linear(duration: 0.25)) { search = "" }
                                withAnimation(.linear(duration: 0.25)) { inputIsActive = false }
                            } label: {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 10)
                                        .frame(width: 40, height: 40)
                                        .foregroundColor(Color("cLessDarkGray"))
                                        .shadow(radius: 2)
                                    Image(systemName: "xmark")
                                        .foregroundColor(.red)
                                }
                            }
                            .buttonStyle(CButton())
                            
                            Button {
                                withAnimation(.linear(duration: 0.25)) { inputIsActive = false }
                            } label: {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 10)
                                        .frame(width: 40, height: 40)
                                        .foregroundColor(Color("cLessDarkGray"))
                                        .shadow(radius: 2)
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.green)
                                }
                            }
                            .buttonStyle(CButton())
                        } else if inputIsActive {
                            Button {
                                withAnimation(.linear(duration: 0.25)) { inputIsActive = false }
                            } label: {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 10)
                                        .frame(width: 40, height: 40)
                                        .foregroundColor(Color("cLessDarkGray"))
                                        .shadow(radius: 2)
                                    Image(systemName: "xmark")
                                        .foregroundColor(.red)
                                }
                            }
                            .buttonStyle(CButton())
                        }
                    }
                    .padding(12.0)
                    
                    ScrollView {
                        VStack(spacing: 0) {
                            ForEach(searchStations, id: \.self) { station in
                                Button {
                                    selectedItem = Item(complex: station)
                                    for favoriteStation in favoriteStations {
                                        if favoriteStation.complexID == station.id {
                                            fromFavorites = true
                                            break
                                        }
                                        fromFavorites = false
                                    }
                                } label: {
                                    StationRow(complex: station)
                                        .frame(width: geometry.size.width-12)
                                }
                                .buttonStyle(CButton())
                            }
                        }
                        
                        // MARK: - Favorites
                        
                        if search.isEmpty {
                            HStack {
                                Text("Favorites")
                                    .padding(.horizontal, 12)
                                    .padding(.bottom, -4)
                                Spacer()
                            }
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack {
                                    ForEach(favoriteStations, id: \.self) { station in
                                        Button {
                                            chosenStation = Int(station.chosenStationNumber)
                                            fromFavorites = true
                                            selectedItem = Item(complex: correctComplex(Int(station.complexID)))
                                        } label: {
                                            ZStack {
                                                RoundedRectangle(cornerRadius: 10)
                                                    .foregroundColor(Color("cLessDarkGray"))
                                                    .shadow(radius: 2)
                                                    .frame(width: 150,height: 82)
                                                StationBox(complex: correctComplex(Int(station.complexID)))
                                                    .frame(width: 150,height: 82)
                                            }
                                            .padding(.vertical, 4)
                                        }
                                        .buttonStyle(CButton())
                                    }
                                }
                                .padding(.leading,12)
                            }
                            .padding(.vertical, 12.0)
                            
                            // MARK: - Nearby
                            HStack {
                                Text("Nearby")
                                    .padding(.horizontal, 12)
                                    .padding(.bottom, -4)
                                Spacer()
                            }
                            switch locationViewModel.authorizationStatus {
                            case .notDetermined:
                                Text("")
                                    .onAppear { locationViewModel.requestPermission() }
                            case .denied:
                                Text("location not shared, go to settings to enable it")
                            case .authorizedAlways, .authorizedWhenInUse:
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack {
                                        ForEach(stations, id: \.self) { station in
                                            Button {
                                                selectedItem = Item(complex: station)
                                                
                                                for favoriteStation in favoriteStations {
                                                    if favoriteStation.complexID == station.id {
                                                        fromFavorites = true
                                                        break
                                                    }
                                                    fromFavorites = false
                                                }

                                            } label: {
                                                ZStack {
                                                    RoundedRectangle(cornerRadius: 10)
                                                        .foregroundColor(Color("cLessDarkGray"))
                                                        .shadow(radius: 2)
                                                        .frame(width: 150,height: 82)
                                                    StationBox(complex: station)
                                                        .frame(width: 150,height: 82)
                                                }
                                                .padding(.vertical, 4)
                                            }
                                            .buttonStyle(CButton())
                                        }
                                    }
                                    .padding(.leading,12)
                                }
                                .padding(.vertical, 12.0)
                                .onAppear {
                                    lookForNearbyStations()
                                }
                            default:
                                Text("Unexpected status")
                            }
                        }
                    }
                    .sheet(item: $selectedItem) { item in
                        if fromFavorites {
                            // chosen station = favoriteStationNumber thing
                            StationView(complex: item.complex, chosenStation: chosenStation, isFavorited: true)
                                .environment(\.managedObjectContext, persistedContainer.viewContext)
                        } else {
                            StationView(complex: item.complex, chosenStation: 0, isFavorited: false)
                                .environment(\.managedObjectContext, persistedContainer.viewContext)
                        }
                    }
                }
            }
        }
    }
}

struct Home_Previews: PreviewProvider {
    static var previews: some View {
        let persistedContainer = CoreDataManager.shared.persistentContainer
        Home()
            .environment(\.managedObjectContext, persistedContainer.viewContext)
    }
}
