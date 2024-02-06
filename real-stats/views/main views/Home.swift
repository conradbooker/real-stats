//
//  Home.swift
//  real-stats
//
//  Created by Conrad on 3/20/23.
//

import SwiftUI
import CoreLocation
import BottomSheet

func rand() -> Int {
    return Int.random(in: 1..<445)
}

struct Item: Identifiable {
    let id = UUID()
    let complex: Complex
}

struct BusItem: Identifiable {
    let id = UUID()
    let stopID: String
}

//var exampleStationTimes: NewTimes = load("608.json")

func correctComplex(_ id: Int) -> Complex {
    for station in complexData {
        if station.id == id {
            return station
        }
    }
    return complexData[0]
}

struct Home: View {
    
    @EnvironmentObject var versionCheck: VersionCheck
        
    @State var bottomSheetPosition: BottomSheetPosition = .relative(0.6)
    @State var lastBottomSheetPosition: BottomSheetPosition?
    @State var sheetWidth = UIScreen.screenWidth-40
    
    @State var bottomSheetSize = CGSize()
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
    @State var selectedBusStop: BusItem?

    @State var fromFavorites: Bool = false
    @State var chosenStation: Int = 0
    
    @FetchRequest(entity: FavoriteStation.entity(), sortDescriptors: [NSSortDescriptor(key: "dateCreated", ascending: false)]) private var favoriteStations: FetchedResults<FavoriteStation>
    
//    private func getNearByStations(_ location: MK)
//    for station in stations, if station.location choser than station-1, set.add

    @State var searchStations: [Complex] = []
    @State var searchBusStops: [BusStop_Array] = []

    @FocusState var inputIsActive: Bool
    
    @AppStorage("stationTimes", store: UserDefaults(suiteName: "group.Schematica.real-stats")) var timeData: String = ""
    
    @AppStorage("version") var version: String = "1.0"
    @State var showWhatsNew = false
    @State var showNeedsUpdate = false

    @State private var duration = 0.2
    @State private var bounce = 0.2
    
    @State private var previouslySelectedSearchType: String = ""
    
    let bundleId = Bundle.main.infoDictionary?["CFBundleIdentifier"] as? String
    
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
    
    func getNearByBusStops(coordinate: CLLocationCoordinate2D) -> [String] {
        let currentLoc = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        let stations = busData_array
            .sorted(by: {
                return $0.location.distance(from: currentLoc) < $1.location.distance(from: currentLoc)
            })
        var newStations = [String]()
        
        for num in 0...15 {
            newStations.append(stations[num].id)
        }
                
        return newStations
    }

    func needsUpdate() -> Bool {
        if versionCheck.isUpdateAvailable {
            return true
        }
        return false
    }
    
    let searchTypes = ["Subway / PATH", "Bus", "Regional Rail"]
    @State var selectedSearchType = "Subway / PATH"
    @State var showTypes = false
    
    @State private var keyboardHeight: CGFloat = 0
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                MapView()
//                Text("hiii")
                    .onAppear {
                        if version != (Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "") {
                            showWhatsNew = true
                            version = (Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "")
                        }
                        print(version, (Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""))
                    }
                    .environment(\.managedObjectContext, CoreDataManager.shared.persistentContainer.viewContext)
                    .environmentObject(locationViewModel)
                    .frame(width: UIScreen.screenWidth, height: UIScreen.screenHeight)
                    .padding(.leading, -UIScreen.screenWidth)
                Spacer().frame(width: 0.01,height: 0.01)
                    .frame(width: UIScreen.screenWidth, height: UIScreen.screenHeight)
                    


                    .bottomSheet(bottomSheetPosition: self.$bottomSheetPosition, switchablePositions: [
                        .relativeBottom(0.31),
                        .relative(0.6),
                        .relativeTop(0.975)
                    ]
                    , headerContent: {
// MARK: - HEADER
                        if search.isEmpty {
                            Text(selectedSearchType)
                                .font(.title)
                                .fontWeight(.bold)
                                .padding(.leading,12)
                        }
                    }
                    ) {
                        ScrollView {
                            VStack(spacing: 0) {
// MARK: - SEARCH - Subway
                                if selectedSearchType == "Subway / PATH" {
                                    ForEach(searchStations, id: \.self) { station in
                                        Button {
                                            DispatchQueue.main.async {
                                                selectedItem = Item(complex: station)
                                                for favoriteStation in favoriteStations {
                                                    if favoriteStation.complexID == station.id {
                                                        fromFavorites = true
                                                        break
                                                    }
                                                    fromFavorites = false
                                                }
                                            }
                                        } label: {
                                            StationRow(complex: station)
                                                .frame(width: geometry.size.width-12)
                                        }
                                        .buttonStyle(CButton())
                                    }
                                    if !search.isEmpty {
                                        Spacer().frame(height: 200 + keyboardHeight)
                                        
                                    }
                                }
// MARK: - SEARCH - Bus
//                                else if selectedSearchType == "Bus" {
//                                    ForEach(searchBusStops, id: \.self) { stop in
//                                        
//                                        Button {
////                                            selectedItem = Item(complex: station)
////                                            for favoriteStation in favoriteStations {
////                                                if favoriteStation.complexID == station.id {
////                                                    fromFavorites = true
////                                                    break
////                                                }
////                                                fromFavorites = false
////                                            }
//                                        } label: {
//                                            BusSearchRow(stop_id: stop.id)
//                                                .frame(width: geometry.size.width-12)
//                                        }
//                                        .buttonStyle(CButton())
//                                    }
//                                }
// MARK: - SEARCH - Regional Rail
                                else {
                                    
                                }
                            }
                            
// MARK: - MAIN CONTENT - Subway
                            if search.isEmpty && selectedSearchType == "Subway / PATH" {
                                HStack {
                                    Text("Favorites")
                                        .padding(.horizontal, 12)
                                        .padding(.bottom, -20)
                                        .padding(.top,4)
                                    Spacer()
                                }
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack {
                                        ForEach(favoriteStations, id: \.self) { station in
                                            Button {
                                                DispatchQueue.main.async {
                                                    chosenStation = Int(station.chosenStationNumber)
                                                    fromFavorites = true
                                                    selectedItem = Item(complex: correctComplex(Int(station.complexID)))
                                                }
                                            } label: {
                                                ZStack {
                                                    Color.clear
                                                        .background(.regularMaterial)
                                                        .cornerRadius(10)
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
                                        .padding(.bottom, -10)
                                        .padding(.top, -10)
                                    Spacer()
                                }
                                //                            Text("location: \(coordinate?.latitude ?? 0)")
                                //                            Text("location: \(coordinate?.longitude ?? 0)")
                                switch locationViewModel.authorizationStatus {
                                case .notDetermined:
                                    Text("request permission")
                                case .denied:
                                    Text("Location is not shared, please go to Settings to enable it.")
                                case .authorizedAlways, .authorizedWhenInUse:
                                    ScrollView(.horizontal, showsIndicators: false) {
                                        HStack {
                                            ForEach(lookForNearbyStations(), id: \.self) { station in
                                                Button {
                                                    DispatchQueue.main.async {
                                                        selectedItem = Item(complex: station)
                                                        
                                                        for favoriteStation in favoriteStations {
                                                            if favoriteStation.complexID == station.id {
                                                                fromFavorites = true
                                                                chosenStation = Int(favoriteStation.chosenStationNumber)
                                                                break
                                                            }
                                                            fromFavorites = false
                                                        }
                                                    }
                                                } label: {
                                                    ZStack {
                                                        Color.clear
                                                            .background(.regularMaterial)
                                                            .cornerRadius(10)
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
                                    .padding(.bottom, 12.0)
                                    .padding(.top, 6)
                                default:
                                    Text("Unexpected status")
                                }

                                
                            }
// MARK: - MAIN CONTENT - Bus
                            else if search.isEmpty && selectedSearchType == "Bus" {
                                // find near by bus stops (0.25 mile radius)
                                // make POST request for multiple bus stops
                                BusView(coordinate: coordinate ?? CLLocationCoordinate2D(latitude: 0, longitude: 0))
                                
                            }
// MARK: - MAIN CONTENT - Regional Rail
                            else if selectedSearchType == "Regional Rail" {
                                Text("Coming soon!")
                                    .padding(20)
                            }
                        }
//                        .scrollDismissesKeyboard(.interactively)
                        .sheet(item: $selectedItem) { item in
                            if fromFavorites {
                                // chosen station = favoriteStationNumber thing
                                StationView(complex: item.complex, chosenStation: chosenStation, isFavorited: true)
                                    .environment(\.managedObjectContext, persistedContainer.viewContext)
                                    .syncLayoutOnDissappear()
                            } else {
                                StationView(complex: item.complex, chosenStation: 0, isFavorited: false)
                                    .environment(\.managedObjectContext, persistedContainer.viewContext)
                                    .syncLayoutOnDissappear()
                            }
                        }
//                        .sheet(item: $selectedBusStop) { item in
//                            BusStopView(stopID: item.stopID)
//                                .syncLayoutOnDissappear()
//                        }
                    }
    //                .customAnimation(.linear.speed(0.4))
                    .customAnimation(.spring(response: 0.3, dampingFraction: 0.825))
                    
                    .enableBackgroundBlur(false)
                    .customBackground(
                        Color.clear
                            .background(.thickMaterial)
                            .environment(\.colorScheme,colorScheme)
                            .cornerRadius(20, corners: [.topLeft, .topRight])
                            .shadow(radius: 2)
                    )
                    .sheetWidth(BottomSheetWidth.absolute(sheetWidth))
                    .padding(.leading, (UIScreen.screenWidth-sheetWidth)/2)
//              MARK: - START Input Field
                VStack {
                    Spacer()
                    ZStack {
                        VStack {
                            Spacer()
// MARK: - START Search Type Selector
                            if search.isEmpty {
                                    ZStack {
                                    Color.clear
                                        .background(.regularMaterial)
                                        .environment(\.colorScheme,colorScheme)
                                        .cornerRadius(20, corners: [.topLeft, .topRight])
                                        .shadow(radius: 2)
                                    VStack {
                                        HStack {
                                            Spacer()
                                                .frame(width: 9)
                                            ForEach(searchTypes, id: \.self) { type in
                                                Button {
                                                    selectedSearchType = type
                                                    if previouslySelectedSearchType == "Bus" {
                                                        bottomSheetPosition = lastBottomSheetPosition ?? .relative(0.6)
                                                        previouslySelectedSearchType = ""
                                                    } else if selectedSearchType == "Bus" {
                                                        lastBottomSheetPosition = bottomSheetPosition
                                                        bottomSheetPosition = .relativeTop(0.975)
                                                        previouslySelectedSearchType = "Bus"
                                                    }
                                                    
                                                } label: {
                                                    if type == selectedSearchType {
                                                        Text(type)
                                                            .padding(.horizontal,5)
                                                            .background(
                                                                Color.clear
                                                                    .padding()
                                                                    .padding(.horizontal,5)
                                                                    .background(.ultraThinMaterial)
                                                                    .cornerRadius(12)
                                                                    .shadow(radius: 2)
                                                                
                                                            )
                                                    } else {
                                                        Text(type)
                                                            .padding(.horizontal,5)
                                                            .opacity(0.5)
                                                    }
                                                }
                                                .buttonStyle(CButton())
                                            }
                                            Spacer()
                                        }
                                        Spacer()
                                            .frame(height: 60 + keyboardHeight)
                                    }
                                    
                                }
                                    .frame(width: sheetWidth, height: 110 + keyboardHeight)
                                    .padding(.bottom,30)
                            }
                        }

                        VStack {
                            Spacer()
                            Color.clear
                                .background(.regularMaterial)
                                .environment(\.colorScheme,colorScheme)
                                .cornerRadius(20, corners: [.topLeft, .topRight])
                                .shadow(radius: 2)
                                .frame(height: 110 + keyboardHeight)
                                .padding(.bottom,-20)
                        }

                        VStack {
                            Spacer()
                            HStack {
                                ZStack {
                                    Color.clear
                                        .background(.ultraThinMaterial)
                                        .environment(\.colorScheme,colorScheme)
                                        .cornerRadius(10)
                                        .shadow(radius: 2)
                                        .frame(height: 40)
                                    TextField("Search for a station or a train", text: $search)
                                        .padding(.leading,6)
                                        .focused($inputIsActive)
                                        .onChange(of: search) { _ in
                                            if search.isEmpty {
                                                searchStations = []
                                                searchBusStops = []
                                                withAnimation(.spring(blendDuration: 0.25)) {
                                                    sheetWidth = UIScreen.screenWidth - 40
                                                }

                                            } else {
                                                bottomSheetPosition = .relative(0.975)
                                                withAnimation(.spring(blendDuration: 0.25)) {
                                                    sheetWidth = UIScreen.screenWidth
                                                }
                                                let currentLoc = CLLocation(latitude: coordinate?.latitude ?? 0, longitude: coordinate?.longitude ?? 0)
                                                
                                                if selectedSearchType == "Subway / PATH" {
                                                    withAnimation(.spring(blendDuration: 0.25)) {
                                                        searchStations = complexData.filter { $0.searchName.localizedCaseInsensitiveContains(search)
                                                        }.sorted(by: {
                                                            return $0.location.distance(from: currentLoc) < $1.location.distance(from: currentLoc)
                                                        })
                                                    }
                                                } else if selectedSearchType == "Bus" {
                                                    withAnimation(.spring(blendDuration: 0.25)) {
                                                        searchBusStops = busData_array.filter { $0.name.localizedCaseInsensitiveContains(search)
                                                        }.sorted(by: {
                                                            return $0.location.distance(from: currentLoc) < $1.location.distance(from: currentLoc)
                                                        })
                                                        if searchBusStops.count > 41 {
                                                            let arraySlice = searchBusStops[0..<41]
                                                            searchBusStops = Array(arraySlice)

                                                        }
                                                    }
                                                }
                                            }
                                        }
                                }
                                .onTapGesture {
                                    inputIsActive = true
                                    selectedSearchType = "Subway / PATH"
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
                                    .onAppear {
                                        selectedSearchType = "Subway / PATH"
                                    }
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
                                    .onAppear {
                                        selectedSearchType = "Subway / PATH"
                                    }
                                }
                            }
                            .padding(.bottom, 26 + keyboardHeight)
                            .padding(12.0)
                            .onTapGesture {
                                self.bottomSheetPosition = .relativeTop(0.975)
                        }
                        }
                    }

                }
                .frame(width: UIScreen.screenWidth,height: UIScreen.screenHeight)
                .padding(.leading, -UIScreen.screenWidth)
                .ignoresSafeArea()
                
//                MARK: - Dark material at the top
                VStack {
                    Rectangle()
                        .frame(width: UIScreen.screenWidth * 2, height: geometry.safeAreaInsets.top)
                        .background(.ultraThinMaterial)
                        .blur(radius: 20)
                        .padding(.top, -20)
                    Spacer()
                }
                .ignoresSafeArea()
            }

        }
        .sheet(isPresented: $showWhatsNew, onDismiss: {
            locationViewModel.requestPermission()
        }, content: WhatsNew.init)
        .sheet(isPresented: $versionCheck.isUpdateAvailable) {
            Update()
        }
        .onAppear {
            NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) { notification in
                if let keyboardSize = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                    withAnimation(.spring(blendDuration: 0.01)) {
                        self.keyboardHeight = keyboardSize.height-26
                        bottomSheetPosition = .relative(0.975)
                    }
                }
            }

            NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { _ in
                withAnimation(.spring(blendDuration: 0.01)) {
                    self.keyboardHeight = 0
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
            .environmentObject(LocationViewModel())
            .environmentObject(VersionCheck())
    }
}
