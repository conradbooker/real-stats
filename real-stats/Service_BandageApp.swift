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

    
    var body: some Scene {
        WindowGroup {
            BottomSheet()
                .environment(\.managedObjectContext, persistentContainer.viewContext)
                .environmentObject(locationViewModel)
        }
    }
}

