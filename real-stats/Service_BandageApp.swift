//
//  real_statsApp.swift
//  real-stats
//
//  Created by Conrad on 2/8/23.
//

import SwiftUI

@main
struct Service_BandageApp: App {
    let persistentContainer = CoreDataManager.shared.persistentContainer
    @StateObject var locationViewModel = LocationViewModel()
    @StateObject var versionCheck = VersionCheck()
    
    @AppStorage("darkMode") var darkMode: Int = 2
    @Environment(\.colorScheme) var colorScheme

    private func getColorScheme() -> ColorScheme {
        if darkMode == 0 {
            return .light
        } else if darkMode == 1 {
            return .dark
        }
        print(colorScheme)
        if (colorScheme == .dark) {
            return .dark
        }
        return .light
    }

    
    var body: some Scene {
        WindowGroup {
            BottomSheet()
                .onAppear {
                    versionCheck.checkVersion()
                }
                .environment(\.managedObjectContext, persistentContainer.viewContext)
                .environmentObject(locationViewModel)
                .environmentObject(versionCheck)
        }
    }
}

