//
//  BottomSheet.swift
//  real-stats
//
//  Created by Conrad on 6/11/23.
//

import SwiftUI
import BottomSheet
import CoreLocation

struct BottomSheet: View {
        
    @State var bottomSheetPosition: BottomSheetPosition = .relative(0.4)
    let backgroundColors: [Color] = [Color(red: 0.28, green: 0.28, blue: 0.53), Color(red: 1, green: 0.69, blue: 0.26)]
    
    @Environment(\.managedObjectContext) private var viewContext
    let persistedContainer = CoreDataManager.shared.persistentContainer
    @EnvironmentObject var locationViewModel: LocationViewModel
    var coordinate: CLLocationCoordinate2D? {
        locationViewModel.lastSeenLocation?.coordinate
    }
    
    @State private var search: String = ""
    @State private var showStation: Bool = false
    @State private var complex: Complex = complexData[0]
    @State var selectedItem: Item?
    
    @State var fromFavorites: Bool = false
    @State var chosenStation: Int = 0
    
    @FetchRequest(entity: FavoriteStation.entity(), sortDescriptors: [NSSortDescriptor(key: "dateCreated", ascending: false)]) private var favoriteStations: FetchedResults<FavoriteStation>
    
//    private func getNearByStations(_ location: MK)
//    for station in stations, if station.location choser than station-1, set.add

    @State var searchStations: [Complex] = []
    
    @FocusState var inputIsActive: Bool
    
    @AppStorage("stationTimes", store: UserDefaults(suiteName: "group.Schematica.real-stats")) var timeData: String = ""
    
    func returnLocation() -> CLLocationCoordinate2D? {
        return coordinate
    }
    
    func correctComplex(_ id: Int) -> Complex {
        for station in complexData {
            if station.id == id {
                return station
            }
        }
        return complexData[0]
    }
    
    func lookForNearbyStations() -> [Complex] {
        let currentLoc = CLLocation(latitude: coordinate?.latitude ?? 0, longitude: coordinate?.longitude ?? 0)
        
        let stations = complexData
            .sorted(by: {
                return $0.location.distance(from: currentLoc) < $1.location.distance(from: currentLoc)
        })
        
        var newStations = [Complex]()
        
        for num in 0...10 {
            newStations.append(stations[num])
        }
                
        return newStations
    }

    
    var body: some View {
        GeometryReader { geometry in
            MapView()
                .environment(\.managedObjectContext, CoreDataManager.shared.persistentContainer.viewContext)
                .environmentObject(LocationViewModel())
//                .ignoresSafeArea()

                .bottomSheet(bottomSheetPosition: self.$bottomSheetPosition, switchablePositions: [
                    .relativeBottom(0.125),
                    .relative(0.4),
                    .relativeTop(0.975)
                ], headerContent: {
                    
                    ZStack {
                        Group {
                            VStack {
                                Rectangle()
                                    .frame(width:50,height:10)
                                    .padding(.top,-20)
                                    .foregroundColor(Color("cDarkGray"))
                                Spacer()
                                    .frame(height: 20)
                                
                            }
                            VStack {
                                Capsule()
                                    .fill(Color("second"))
                                    .frame(width: 34, height: 4.5)
                                    .padding(.top, -15)
                                Spacer()
                                    .frame(height: 30)
                            }
                        }.padding(.top, -17)
                        .padding(12.0)
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
                                            let currentLoc = CLLocation(latitude: coordinate?.latitude ?? 0, longitude: coordinate?.longitude ?? 0)
                                            
                                            
                                            withAnimation(.spring(blendDuration: 0.25)) {
                                                searchStations = complexData.filter { $0.complexName.localizedCaseInsensitiveContains(search)
                                                }.sorted(by: {
                                                    return $0.location.distance(from: currentLoc) < $1.location.distance(from: currentLoc)
                                                })
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
                        .padding(.top, -17)
                        .padding(12.0)
                        .onTapGesture {
                            self.bottomSheetPosition = .relativeTop(0.975)
                    }
                    }
                }) {
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
                                    .padding(.bottom, -20)
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
                                                    .frame(width: 130,height: 82)
                                                StationBox(complex: correctComplex(Int(station.complexID)))
                                                    .frame(width: 130,height: 82)
                                            }
                                            .padding(.vertical, 4)
                                        }
                                        .buttonStyle(CButton())
                                    }
                                }
                                .padding(.horizontal,12)
                            }
                            .padding(.vertical, 12.0)
                            
                            // MARK: - Nearby
                            HStack {
                                Text("Nearby")
                                    .padding(.horizontal, 12)
                                    .padding(.bottom, -20)
                                Spacer()
                            }
                            //                            Text("location: \(coordinate?.latitude ?? 0)")
                            //                            Text("location: \(coordinate?.longitude ?? 0)")
                            switch locationViewModel.authorizationStatus {
                            case .notDetermined:
                                Text("request permission")
                                    .onAppear { locationViewModel.requestPermission() }
                            case .denied:
                                Text("Location is not shared, please go to Settings to enable it.")
                            case .authorizedAlways, .authorizedWhenInUse:
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack {
                                        ForEach(lookForNearbyStations(), id: \.self) { station in
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
                                                        .frame(width: 130,height: 82)
                                                    StationBox(complex: station)
                                                        .frame(width: 130,height: 82)
                                                }
                                                .padding(.vertical, 4)
                                            }
                                            .buttonStyle(CButton())
                                        }
                                    }
                                    .padding(.horizontal,12)
                                }
                                .padding(.vertical, 12.0)
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
//                .customAnimation(.linear.speed(0.4))
                .enableBackgroundBlur(false)
                .customBackground(
                    Color("cDarkGray")
                        .cornerRadius(20)
                        .shadow(color: .gray, radius: 10, x: 0, y: 0)
                )

        }
    }
}
struct BottomSheet_Previews: PreviewProvider {
    static var previews: some View {
        let persistedContainer = CoreDataManager.shared.persistentContainer
        BottomSheet()
            .environment(\.managedObjectContext, persistedContainer.viewContext)
            .environmentObject(LocationViewModel())
    }
}
