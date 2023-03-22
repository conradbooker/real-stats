//
//  FavoriteBox.swift
//  real-stats
//
//  Created by Conrad on 3/13/23.
//

import SwiftUI

struct FavoriteBox: View {
    var stationName: String
    var body: some View {
        VStack(spacing: 0) {
            Text(stationName)
                .font(.title3)
                .padding(.horizontal, 12)
            Text("1, 2, 3, 4, 5, 6, 7, 8, 9, 10")
                .padding([.top, .leading, .trailing], 12)
            Spacer()
        }
    }
}

struct FavoriteBox_Previews: PreviewProvider {
    static var previews: some View {
        FavoriteBox(stationName: "Grand Central-42 St")
            .previewLayout(.fixed(width: 150, height: 100))
    }
}
