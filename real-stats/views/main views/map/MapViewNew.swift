//
//  MapViewNew.swift
//  Service Bandage
//
//  Created by Conrad on 8/6/23.
//

import SwiftUI
import Map
import CoreLocation
import Foundation
import UIKit
import MapKit

struct content: View {
    @State private var isScaled = false

    var body: some View {
        VStack {
            Text("Tap to Scale")
                .scaleEffect(isScaled ? 1.5 : 1.0) // Apply scale effect conditionally
                .onTapGesture {
                    withAnimation {
                        isScaled.toggle()
                    }
                }

            Circle()
                .frame(width: 100, height: 100)
                .foregroundColor(.blue)
                .scaleEffect(isScaled ? 1.5 : 1.0) // Apply scale effect conditionally
                .onTapGesture {
                    withAnimation {
                        isScaled.toggle()
                    }
                }

            Rectangle()
                .frame(width: 100, height: 50)
                .foregroundColor(.green)
                .scaleEffect(isScaled ? 1.5 : 1.0) // Apply scale effect conditionally
                .onTapGesture {
                    withAnimation {
                        isScaled.toggle()
                    }
                }
        }
        .padding()
    }
}

struct content_Previews: PreviewProvider {
    static var previews: some View {
        content()
            .environment(\.managedObjectContext, CoreDataManager.shared.persistentContainer.viewContext)
            .environmentObject(LocationViewModel())
    }
}
