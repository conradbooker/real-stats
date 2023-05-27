//
//  Delay.swift
//  real-stats
//
//  Created by Conrad on 3/13/23.
//

import SwiftUI

struct Delay: View {
    var lines: [String]
    var GTFSID: String
    var body: some View {
        Text("Hello, World!")
    }
}

struct Delay_Previews: PreviewProvider {
    static var previews: some View {
        Delay(lines: ["B","C"], GTFSID: "ACde")
            .previewLayout(.fixed(width: 400, height: 80))
    }
}
