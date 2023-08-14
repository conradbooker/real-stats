//
//  Preferences.swift
//  real-stats
//
//  Created by Conrad on 3/13/23.
//

import SwiftUI
import MessageUI

struct ToggleButton: ButtonStyle {
    var color: Color
    func makeBody(configuration: Configuration) -> some View {
        if #available(iOS 16.0, *) {
            configuration.label
                .fontWeight(.semibold)
                .padding(5.0)
                .background(color)
                .foregroundColor(.white)
                .cornerRadius(10)
                .shadow(radius: 2)
        } else {
            configuration.label
                .padding(5.0)
                .background(color)
                .foregroundColor(.white)
                .cornerRadius(10)
                .shadow(radius: 2)
        }
    }
}


struct Preferences: View {
    @State private var isSheetExpanded = true
    @State private var showAbout = false
    @State private var showFeedback = false
    @State private var alertNoMail = false
    @GestureState private var dragOffset: CGFloat = 0
    @AppStorage("darkMode") var darkMode: Int = 0
    @State var result: Result<MFMailComposeResult, Error>? = nil
    
    private let pastboard = UIPasteboard.general

    var body: some View {
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

                                        Text("Version: 1.0")
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
                                Text("Timeline:\nPATH - September 2023\nNJ Transit Light Rail - October 2023\nNYC Buses - December 2023\nLIRR, MetroNorth - March 2024\nNJ Transit Rail + Buses - March 2024\nCTRail - June 2024\n\nOther Systems:\nBoston, Philadelphia, Chicago, Baltimore / DC, Montreal, Toronto - 2024\nLA, San Francisco, London, Paris - 2025\n\nLicensing: Route indicators used with permission of the Metropolitan Transportation Agency.\n\n**Please note**: Transit Bandage uses data provided by the MTA's data feed. If there are disrepencies with their data, there are descrepencies with out data")
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
    }
}

struct Preferences_Previews: PreviewProvider {
    static var previews: some View {
        Preferences()
    }
}
