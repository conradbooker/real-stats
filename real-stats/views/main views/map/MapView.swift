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
                  annotationItems: favoriteStations,
                  annotationContent: { station in
                      ViewMapAnnotation(coordinate: correctComplex(Int(station.complexID)).location.coordinate) {
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
                                  Text(correctComplex(Int(station.complexID)).stations[0].short1)
                                      .foregroundColor(Color("whiteblack"))
                                      .frame(width: 1000)
                                  if correctComplex(Int(station.complexID)).stations[0].short2 != "" {
                                      Text(correctComplex(Int(station.complexID)).stations[0].short2)
                                          .foregroundColor(Color("whiteblack"))
                                          .font(.footnote)
                                          .frame(width: 1000)
                                  }
                                  HStack(spacing: 2) {
                                      ForEach(correctComplex(Int(station.complexID)).stations, id: \.self) { station in
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
                                  selectedItem = Item(complex: correctComplex(Int(station.complexID)))
                                  for favoriteStation in favoriteStations {
                                      if favoriteStation.complexID == correctComplex(Int(station.complexID)).id {
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
                            withAnimation(.linear(duration: 0.4)) {
                                locationViewModel.region = MKCoordinateRegion(
                                    center: CLLocationCoordinate2D(latitude: (coordinate?.latitude ?? 40.791642) - 0.005, longitude: coordinate?.longitude ?? -73.964696),
                                    span: MKCoordinateSpan(latitudeDelta: 0.025, longitudeDelta: 0.025))
                            }
                        } label: {
                            ZStack {
                                RoundedRectangle(cornerRadius: 10)
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
                        .padding(.top,-10)
                    }
                    Spacer()
                }
            }
            
        }
        .sheet(item: $selectedItem) { item in
            if #available(iOS 16.0, *) {
                if fromFavorites {
                    // chosen station = favoriteStationNumber thing
                    StationView(complex: item.complex, chosenStation: chosenStation, isFavorited: true)
                        .environment(\.managedObjectContext, persistedContainer.viewContext)
                } else {
                    StationView(complex: item.complex, chosenStation: 0, isFavorited: false)
                        .environment(\.managedObjectContext, persistedContainer.viewContext)
                }
            } else {
                if fromFavorites {
                    // chosen station = favoriteStationNumber thing
                    StationViewOld(complex: item.complex, chosenStation: chosenStation, isFavorited: true)
                        .environment(\.managedObjectContext, persistedContainer.viewContext)
                } else {
                    StationViewOld(complex: item.complex, chosenStation: 0, isFavorited: false)
                        .environment(\.managedObjectContext, persistedContainer.viewContext)
                }
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

                                            Text("Version: 1.1")
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
                            .frame(width: geometry.size.width-20)
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
                                    Text("Timeline:\nLIRR / Metro North - September 2023\nNYC Buses - September 2023\nNJ Transit Rail + Buses - March 2024\nCTRail - June 2024\n\nOther Systems:\nBoston, Philadelphia, Chicago, Baltimore / DC, Montreal, Toronto - 2024\nLA, San Francisco, London, Paris - 2025\n\nLicensing: Route indicators used with permission of the Metropolitan Transportation Agency.\n\n**Please note**: Transit Bandage uses data provided by the MTA's data feed. If there are discrepancies with their data, there are discrepancies with out data.")
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
