//
//  real_statsApp.swift
//  real-stats
//
//  Created by Conrad on 2/8/23.
//

import SwiftUI

@main
struct real_statsApp: App {
    let persistentContainer = CoreDataManager.shared.persistentContainer
    
    var body: some Scene {
        WindowGroup {
            Home()
                .environment(\.managedObjectContext, persistentContainer.viewContext)
        }
    }
}

