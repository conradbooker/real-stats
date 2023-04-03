//
//  FavoriteBox.swift
//  real-stats
//
//  Created by Conrad on 3/13/23.
//

import SwiftUI
import WrappingHStack

struct FavoriteBox: View {
    var complex: Complex
    
    private func allLines() -> [String] {
        var lines = [String]()
        
        for station in complex.stations {
            for line in station.weekdayLines {
                lines.append(line)
            }
        }
        
        return lines
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Spacer()
            HStack {
                Text(complex.stations[0].short1)
                    .padding(.leading, 5)
                if complex.stations[0].ADA > 0 {
                    Image("ADA")
                        .resizable()
                        .frame(width: 20, height: 20)
                }
            }
            Text(complex.stations[0].short2)
                .padding(.leading, 5)
            Spacer()
            WrappingHStack(allLines(), id: \.self, spacing: .constant(2)) { line in
                Image(line)
                    .resizable()
                    .frame(width: 20, height: 20)
                    .padding(.bottom, 2.0)
            }
            .frame(width: 145,height: 44)
            .padding(.leading,5)
            
            Spacer()
        }
    }
}

struct FavoriteBox_Previews: PreviewProvider {
    static var previews: some View {
        FavoriteBox(complex: complexData[429])
            .previewLayout(.fixed(width: 150, height: 100))
    }
}
