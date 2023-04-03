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
    
    @FetchRequest(entity: FavoriteStation.entity(), sortDescriptors: [NSSortDescriptor(key: "dateCreated", ascending: false)]) private var favoriteStations: FetchedResults<FavoriteStation>
    
    var favorites: [Complex] = [complexData[423],complexData[rand()],complexData[rand()],complexData[rand()],complexData[rand()],complexData[rand()]]
    var stations: [Complex] = [complexData[rand()],complexData[rand()],complexData[rand()],complexData[rand()],complexData[rand()],complexData[rand()]]

    @State var searchStations: [Complex] = []
    
    @FocusState var inputIsActive: Bool
    
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
                        ForEach(searchStations, id: \.self) { station in
                            Button {
                                selectedItem = Item(complex: station)
                            } label: {
                                StationRow(complex: station)
                                    .frame(width: geometry.size.width-12)
                            }.buttonStyle(CButton())
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
                                            selectedItem = Item(complex: complexData[Int(station.complexID)])
                                        } label: {
                                            ZStack {
                                                RoundedRectangle(cornerRadius: 5)
                                                    .foregroundColor(Color("cLessDarkGray"))
                                                    .shadow(radius: 2)
                                                    .frame(width: 150,height: 100)
                                                FavoriteBox(complex: complexData[Int(station.complexID)])
                                                    .frame(width: 150,height: 100)
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
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack {
                                    ForEach(stations, id: \.self) { station in
                                        Button {
                                            selectedItem = Item(complex: station)
                                        } label: {
                                            ZStack {
                                                RoundedRectangle(cornerRadius: 5)
                                                    .foregroundColor(Color("cLessDarkGray"))
                                                    .shadow(radius: 2)
                                                    .frame(width: 150,height: 100)
                                                FavoriteBox(complex: station)
                                                    .frame(width: 150,height: 100)
                                            }
                                            .padding(.vertical, 4)
                                        }
                                        .buttonStyle(CButton())
                                    }
                                }
                                .padding(.leading,12)
                            }
                            .padding(.vertical, 12.0)
                        }
                    }
                    .sheet(item: $selectedItem) { item in
                        StationView(complex: item.complex, chosenStation: 0)
                            .environment(\.managedObjectContext, persistedContainer.viewContext)
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
