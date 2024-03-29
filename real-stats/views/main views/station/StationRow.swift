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
                .frame(height: 50)
                .foregroundColor(Color("cLessDarkGray"))
                .shadow(radius: 2)
            HStack {
                VStack(alignment: .leading, spacing: 0) {
                    HStack {
                        Text(complex.stations[0].short1)
                        if complex.stations[0].ADA > 0 {
                            Image("ADA")
                                .resizable()
                                .frame(width: 16, height: 16)
                                .shadow(radius: 2)
                        }

                    }
                    if complex.stations[0].short2 != "" {
                        Text(complex.stations[0].short2)
                            .font(.footnote)
                    }
                }
                .padding(.leading, 5)
                Spacer()
                WrappingHStack(allLines(), id: \.self, alignment: .trailing, spacing: .constant(0)) { line in
                    if line == "PATH" {
                        Image(line)
                            .resizable()
                            .frame(width: 32, height: 16)
                            .padding(1)
                            .shadow(radius: 2)
                    } else {
                        Image(line)
                            .resizable()
                            .frame(width: 16, height: 16)
                            .padding(1)
                            .shadow(radius: 2)
                    }
                }
                .padding()
                .frame(width: 160)
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
