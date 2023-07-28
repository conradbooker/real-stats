//
//  MapView.swift
//  real-stats
//
//  Created by Conrad on 3/13/23.
//

//import SwiftUI
import CoreLocation
import MapKit

import Foundation
import MapKit
import SwiftUI

struct MapView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var locationViewModel: LocationViewModel
    @StateObject var manager = LocationViewModel()
        
    let persistedContainer = CoreDataManager.shared.persistentContainer
    var coordinate: CLLocationCoordinate2D? {
        locationViewModel.lastSeenLocation?.coordinate
    }
    
    @State var selectedItem: Item?
    @State var chosenStation: Int = 0
    
    @State var fromFavorites = false
    
    @FetchRequest(entity: FavoriteStation.entity(), sortDescriptors: [NSSortDescriptor(key: "dateCreated", ascending: false)]) private var favoriteStations: FetchedResults<FavoriteStation>
    
    var body: some View {
        VStack {
            ZStack {
                Map(coordinateRegion: $manager.region, showsUserLocation: true, annotationItems: favoriteStations) { station in
                    MapAnnotation(coordinate: correctComplex(Int(station.complexID)).location.coordinate) {
                        VStack {
                            Spacer()
                                .frame(height: 40)
                            Button {
                                selectedItem = Item(complex: correctComplex(Int(station.complexID)))
                                for favoriteStation in favoriteStations {
                                    if favoriteStation.complexID == correctComplex(Int(station.complexID)).id {
                                        fromFavorites = true
                                        break
                                    }
                                    fromFavorites = false
                                }
                            } label: {
                                VStack(spacing: 0) {
                                    ZStack {
                                        Circle()
                                            .frame(width: 46, height: 46)
                                            .foregroundColor(.black)
                                        Circle()
                                            .frame(width: 40, height: 55)
                                            .foregroundColor(.white)
                                        Image(systemName: "tram")
                                            .resizable()
                                            .frame(width: 20,height:30)
                                            .foregroundColor(.black)
                                    }
                                    Text(correctComplex(Int(station.complexID)).stations[0].short1)
                                        .foregroundColor(Color("whiteblack"))
                                    if correctComplex(Int(station.complexID)).stations[0].short2 != "" {
                                        Text(correctComplex(Int(station.complexID)).stations[0].short2)
                                            .foregroundColor(Color("whiteblack"))
                                            .font(.footnote)
                                    }
                                    HStack(spacing: 2) {
                                        ForEach(correctComplex(Int(station.complexID)).stations, id: \.self) { station in
                                            ForEach(station.weekdayLines, id: \.self) { line in
                                                Image(line)
                                                    .resizable()
                                                    .frame(width: 15,height: 15)
                                            }
                                        }
                                    }

                                }
                            }
                            .buttonStyle(CButton())
                        }
                        .shadow(radius: 2)
                    }
                }
//                VStack {
//                    Rectangle()
//                        .background(.)
//                        .background(Color("cDarkGray"))
//                        .frame(height: 60)
//                    Spacer()
//                }
                VStack {
//                    Spacer()
//                        .frame(height: 60)
                    HStack {
                        Spacer()
                        Button {
                            withAnimation(.linear(duration: 0.4)) {
                                manager.region = MKCoordinateRegion(
                                    center: coordinate ?? CLLocationCoordinate2D(latitude: 40.791642, longitude: -73.964696),
                                    span: MKCoordinateSpan(latitudeDelta: 0.025, longitudeDelta: 0.025))
                            }
                        } label: {
                            ZStack {
                                RoundedRectangle(cornerRadius: 5)
                                    .foregroundColor(Color("cDarkGray"))
                                    .shadow(radius: 2)
                                Image(systemName: "location")
                                    .resizable()
                                    .frame(width: 20,height:20)
                            }
                            .frame(width: 40,height: 40)
                        }
                        .padding()
                    }
                    Spacer()
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

struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        MapView()
            .environment(\.managedObjectContext, CoreDataManager.shared.persistentContainer.viewContext)
            .environmentObject(LocationViewModel())
    }
}
