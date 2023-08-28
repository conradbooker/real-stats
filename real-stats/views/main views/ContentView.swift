//
//  ContentView.swift
//  real-stats
//
//  Created by Conrad on 6/11/23.
//

import SwiftUI
import CoreLocation

@available(iOS 16.0, *)
struct ContentView: View {
    @Environment(\.requestReview) var requestReview

    var body: some View {
        Button("Review the app") {
            requestReview()
        }
    }
}

struct ContentView_Previews: PreviewProvider {

    static var previews: some View {
        if #available(iOS 16.0, *) {
            ContentView()
        } else {
            // Fallback on earlier versions
        }
    }
}
