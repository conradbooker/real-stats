//
//  FavoriteBox.swift
//  real-stats
//
//  Created by Conrad on 3/13/23.
//

import SwiftUI
import WrappingHStack

struct StationBox: View {
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
            HStack {
                Text(complex.stations[0].short1)
                    .padding([.leading,.top], 5)
                Spacer()
                if complex.stations[0].ADA > 0 {
                    Image("ADA")
                        .resizable()
                        .frame(width: 20, height: 20)
                        .padding([.trailing,.top], 5)
                }
            }
            Text(complex.stations[0].short2)
                .padding(.leading, 5)
                .font(.caption)
            WrappingHStack(allLines(), id: \.self, spacing: .constant(2)) { line in
                if line == "PATH" {
                    Image(line)
                        .resizable()
                        .frame(width: 28, height: 14)
                        .shadow(radius: 2)
                        .padding(.bottom, 2.0)
                } else {
                    Image(line)
                        .resizable()
                        .frame(width: 14, height: 14)
                        .shadow(radius: 2)
                        .padding(.bottom, 2.0)
                }
            }
            .frame(width: 115)
            .padding([.leading,.top],5)
            
            Spacer()
        }
    }
}

struct StationBox_Previews: PreviewProvider {
    static var previews: some View {
        StationBox(complex: complexData[429])
            .previewLayout(.fixed(width: 150, height: 100))
    }
}
