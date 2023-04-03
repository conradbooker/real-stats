//
//  StationRow.swift
//  real-stats
//
//  Created by Conrad on 4/2/23.
//

import SwiftUI
import WrappingHStack

struct StationRow: View {
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
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .frame(height: 60)
                .foregroundColor(Color("cLessDarkGray"))
                .shadow(radius: 2)
            HStack {
                Spacer()
                Text(complex.complexName)
                Spacer()
                if complex.stations[0].ADA > 0 {
                    Image("ADA")
                        .resizable()
                        .frame(width: 30, height: 30)
                        .shadow(radius: 2)
                }
                WrappingHStack(allLines(), id: \.self, alignment: .leading, spacing: .constant(0)) { line in
                    Image(line)
                        .resizable()
                        .frame(width: 20, height: 20)
                        .padding(1)
                        .shadow(radius: 2)
                }
                .padding()
                .frame(width: 200)
                Spacer()
            }
        }
        .padding(6)

    }
}

struct StationRow_Previews: PreviewProvider {
    static var previews: some View {
        StationRow(complex: complexData[423])
    }
}
