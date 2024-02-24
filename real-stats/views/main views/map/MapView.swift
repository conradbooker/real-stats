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
import Map
import WrappingHStack
import MessageUI

struct MapView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var locationViewModel: LocationViewModel
        
    let persistedContainer = CoreDataManager.shared.persistentContainer
    var coordinate: CLLocationCoordinate2D? {
        locationViewModel.lastSeenLocation?.coordinate
    }
    
    @State var selectedItem: Item?
    @State var chosenStation: Int = 0
    
    @State var showSettings = false
    
    @State var fromFavorites = false
    
    @FetchRequest(entity: FavoriteStation.entity(), sortDescriptors: [NSSortDescriptor(key: "dateCreated", ascending: false)]) private var favoriteStations: FetchedResults<FavoriteStation>
    @State private var userTrackingMode = UserTrackingMode.follow
    
    @State private var scale: CGFloat = 1
    
    // Vars for the Preferences
    @State private var isSheetExpanded = true
    @State private var showAbout = false
    @State private var showFeedback = false
    @State private var alertNoMail = false
    @GestureState private var dragOffset: CGFloat = 0
    @AppStorage("darkMode") var darkMode: Int = 0
    @State var result: Result<MFMailComposeResult, Error>? = nil
    
    private let pastboard = UIPasteboard.general
    
    @Environment(\.colorScheme) var colorScheme
    
    private func getColorScheme() -> ColorScheme {
        print(colorScheme)
        if (colorScheme == .dark) {
            return .dark
        }
        if darkMode == 0 {
            return .light
        } else if darkMode == 1 {
            return .dark
        }
        return .dark
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
        VStack {
            ZStack {
                Map(
                  coordinateRegion:  $locationViewModel.region,
                  type: .standard,
                  pointOfInterestFilter: .excludingAll,
                  informationVisibility: .default.union(.userLocation),
                  interactionModes: [.pan, .rotate, .zoom],
                  userTrackingMode: $userTrackingMode,
                  annotationItems: lookForNearbyStations(),
                  annotationContent: { station in
                      ViewMapAnnotation(coordinate: correctComplex(Int(station.id)).location.coordinate) {
                          VStack {
                              Spacer()
                                  .frame(height: 40)
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
                                  Text(correctComplex(Int(station.id)).stations[0].short1)
                                      .foregroundColor(Color("whiteblack"))
                                      .frame(width: 1000)
                                  if correctComplex(Int(station.id)).stations[0].short2 != "" {
                                      Text(correctComplex(Int(station.id)).stations[0].short2)
                                          .foregroundColor(Color("whiteblack"))
                                          .font(.footnote)
                                          .frame(width: 1000)
                                  }
                                  HStack(spacing: 2) {
                                      ForEach(correctComplex(Int(station.id)).stations, id: \.self) { station in
                                          ForEach(station.weekdayLines, id: \.self) { line in
                                              if ["LIRR","HBLR","NJT","MNR","PATH"].contains(line) {
                                                  Image(line)
                                                      .resizable()
                                                      .frame(width: 30,height: 15)
                                              } else {
                                                  Image(line)
                                                      .resizable()
                                                      .frame(width: 15,height: 15)
                                              }
                                          }
                                      }
                                  }
                                  
                              }
                              .onTapGesture {
                                  withAnimation(.spring()) {
                                      scale = 0.8
                                  }
                                  selectedItem = Item(complex: correctComplex(Int(station.id)))
                                  for favoriteStation in favoriteStations {
                                      if favoriteStation.complexID == correctComplex(Int(station.id)).id {
                                          fromFavorites = true
                                          break
                                      }
                                      fromFavorites = false
                                  }
                              }
                          }
                      }
                  }
                )
                .ignoresSafeArea()

                VStack {
                    HStack {
                        Spacer()
                        Button {
                            showSettings = true
                        } label: {
                            ZStack {
                                RoundedRectangle(cornerRadius: 10)
                                    .foregroundColor(Color("cDarkGray"))
                                    .shadow(radius: 2)
                                Image(systemName: "gear")
                                    .resizable()
                                    .frame(width: 20,height:20)
                            }
                            .frame(width: 40,height: 40)
                        }
                        .padding(.horizontal)
//                        .padding(.top,-5)
                    }
                    HStack {
                        Spacer()
                        Button {
                            withAnimation(.linear(duration: 0.4)) {
                                locationViewModel.region = MKCoordinateRegion(
                                    center: CLLocationCoordinate2D(latitude: (coordinate?.latitude ?? 40.791642) - 0.005, longitude: coordinate?.longitude ?? -73.964696),
                                    span: MKCoordinateSpan(latitudeDelta: 0.025, longitudeDelta: 0.025))
                                print(abs((coordinate?.latitude ?? 0) - 0.005) - abs(locationViewModel.region.center.latitude), abs((coordinate?.longitude ?? 0)) - abs(locationViewModel.region.center.longitude) )
                            }
                        } label: {
                            ZStack {
                                RoundedRectangle(cornerRadius: 10)
                                    .foregroundColor(Color("cDarkGray"))
                                    .shadow(radius: 2)
                                if abs((coordinate?.latitude ?? 0) - 0.005) - abs(locationViewModel.region.center.latitude) < 0.00001 && abs((coordinate?.longitude ?? 0)) - abs(locationViewModel.region.center.longitude) < 0.00001 {
                                    Image(systemName: "location.fill")
                                        .resizable()
                                        .frame(width: 20,height:20)
                                } else {
                                    Image(systemName: "location")
                                        .resizable()
                                        .frame(width: 20,height:20)
                                }
                            }
                            .frame(width: 40,height: 40)
                            .padding(.top, -5)
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
        .sheet(isPresented: $showSettings) {
            GeometryReader { geometry in
                ZStack {
                    Color("cDarkGray")
                        .ignoresSafeArea()
                    NavigationView {
                        ScrollView {
                            VStack {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 10)
                                        .foregroundColor(Color("cLessDarkGray"))
                                        .shadow(radius: 2)
                                    VStack(alignment: .leading, spacing: 0) {
                                        HStack {
                                            Text("Region: NYC (More regions coming soon)")
                                                .padding()
                                            Spacer()
                                        }
                                        Text("Color Scheme:")
                                            .padding([.top, .leading, .trailing])
                                        HStack {
                                            VStack {
                                                Button {
                                                    darkMode = 0
                                                } label: {
                                                    HStack {
                                                        Text("Light")
                                                            .foregroundColor(.black)
                                                        Image(systemName: "sun.max.fill")
                                                            .foregroundColor(.black)
                                                    }
                                                    .padding(.vertical, 2)
                                                }
                                                .buttonStyle(ToggleButton(color: .white))
                                                if darkMode == 0 {
                                                    RoundedRectangle(cornerRadius: 100)
                                                        .frame(width: 40, height: 5)
                                                        .foregroundColor(Color("blue"))
                                                        .shadow(radius: 2)
                                                } else {
                                                    RoundedRectangle(cornerRadius: 10)
                                                        .frame(width: 40, height: 3)
                                                        .foregroundColor(Color("cLessDarkGray"))
                                                }
                                            }
                                            
                                            VStack {
                                                Button {
                                                    darkMode = 1
                                                } label: {
                                                    HStack {
                                                        Text("Dark")
                                                            .foregroundColor(.white)
                                                        Image(systemName: "moon.fill")
                                                            .foregroundColor(.white)
                                                    }
                                                    .padding(.vertical, 2)
                                                }
                                                .buttonStyle(ToggleButton(color: .black))
                                                if darkMode == 1 {
                                                    RoundedRectangle(cornerRadius: 100)
                                                        .frame(width: 40, height: 5)
                                                        .foregroundColor(Color("blue"))
                                                        .shadow(radius: 2)
                                                } else {
                                                    RoundedRectangle(cornerRadius: 10)
                                                        .frame(width: 40, height: 3)
                                                        .foregroundColor(Color("cLessDarkGray"))
                                                }
                                            }
                                            
                                            VStack {
                                                Button {
                                                    darkMode = 2
                                                } label: {
                                                    HStack {
                                                        Text("System")
                                                            .foregroundColor(.white)
                                                    }
                                                    .padding(.vertical, 2)
                                                }
                                                .buttonStyle(ToggleButton(color: .gray))
                                                if darkMode == 2 {
                                                    RoundedRectangle(cornerRadius: 100)
                                                        .frame(width: 40, height: 5)
                                                        .foregroundColor(Color("blue"))
                                                        .shadow(radius: 2)
                                                } else {
                                                    RoundedRectangle(cornerRadius: 10)
                                                        .frame(width: 40, height: 3)
                                                        .foregroundColor(Color("cLessDarkGray"))
                                                }
                                            }
                                        }
                                        .padding([.top, .leading, .trailing])
                                        
                                        Spacer()
                                    }
                                }
                                .frame(height: 100)
                                Spacer()
                                    .frame(height: 50)
                                ZStack {
                                    RoundedRectangle(cornerRadius: 10)
                                        .foregroundColor(Color("cLessDarkGray"))
                                        .shadow(radius: 2)
                                    HStack {
                                        VStack(alignment: .leading, spacing: 5) {
                                            Button {
                                                showAbout = true
                                            } label: {
                                                Text("About")
                                            }
                                            Button {
                                                if MFMailComposeViewController.canSendMail() {
                                                    showFeedback = true
                                                } else {
                                                    alertNoMail = true
                                                }
                                            } label: {
                                                Text("Send Feedback")
                                            }
                                            .alert("No Email Set Up", isPresented: $alertNoMail, actions: {
                                                Button("Cancel", role: .cancel) { }
                                                Button {
                                                    pastboard.string = "transitbandage@gmail.com"
                                                } label: {
                                                    Label("Copy Email", systemImage: "doc.on.doc")
                                                }
                                            }, message: {
                                                Text("You do not have an email set up. Go to settings, or send the email to \"transitbandage@gmail.com\".")
                                            })

                                            Text("Version: 2.0")
                                            Text("Made with ❤️ in NYC 🗽🥨")
                                        }
                                        .padding(.leading)
                                        Spacer()
                                    }
                                }
                                .frame(height: 130)
                                Spacer()
                                    .frame(height: 20)
                            }
                            .frame(width: UIScreen.screenWidth-20)
                            .padding(.top,40)
                        }
                        .navigationTitle("Settings")
                        .sheet(isPresented: $showAbout) {
                            VStack {
                                HStack {
                                    Text("We value privacy. Transit Bandage does not collect user data.")
                                        .padding()
                                    Spacer()
                                }
                                HStack {
                                    Text(String(format: NSLocalizedString("about-section", comment: "")))
                                        .padding()
                                    Spacer()
                                }
                                Spacer()
                            }
                        }
                        .sheet(isPresented: $showFeedback) {
                            MailView(result: self.$result)
                        }
                    }
                }
            }
            .preferredColorScheme(getColorScheme())
            .syncLayoutOnDissappear()
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
