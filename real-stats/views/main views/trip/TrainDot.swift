//
//  TrainDot.swift
//  real-stats
//
//  Created by Conrad on 6/9/23.
//

import SwiftUI

// This shape was converted from SVG into Swift

struct MyIcon: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.size.width
        let height = rect.size.height
        path.move(to: CGPoint(x: 0.11663*width, y: 0.44553*height))
        path.addCurve(to: CGPoint(x: 0.5*width, y: 0.06215*height), control1: CGPoint(x: 0.11663*width, y: 0.23379*height), control2: CGPoint(x: 0.28827*width, y: 0.06215*height))
        path.addCurve(to: CGPoint(x: 0.88337*width, y: 0.44553*height), control1: CGPoint(x: 0.71173*width, y: 0.06215*height), control2: CGPoint(x: 0.88337*width, y: 0.23379*height))
        path.addCurve(to: CGPoint(x: 0.81617*width, y: 0.66242*height), control1: CGPoint(x: 0.88337*width, y: 0.52603*height), control2: CGPoint(x: 0.85856*width, y: 0.60074*height))
        path.addCurve(to: CGPoint(x: 0.5*width, y: 0.93785*height), control1: CGPoint(x: 0.74706*width, y: 0.76296*height), control2: CGPoint(x: 0.5*width, y: 0.93785*height))
        path.addCurve(to: CGPoint(x: 0.18449*width, y: 0.66337*height), control1: CGPoint(x: 0.5*width, y: 0.93785*height), control2: CGPoint(x: 0.25368*width, y: 0.76338*height))
        path.addCurve(to: CGPoint(x: 0.11663*width, y: 0.44553*height), control1: CGPoint(x: 0.1417*width, y: 0.60151*height), control2: CGPoint(x: 0.11663*width, y: 0.52644*height))
        path.closeSubpath()
        return path
    }
}

struct TrainDot: View {
    var size: CGFloat = 30
    var line: String
    
    var body: some View {
        ZStack {
            VStack {
                Spacer()
                    .frame(height:2.66)
                MyIcon()
                    .frame(width: 37,height: 37)
                    .shadow(radius: 2)
                    .foregroundColor(.white)
            }
            VStack {
                Spacer()
                    .frame(height: 2)
                MyIcon()
                    .frame(width: 33,height: 32)
                    .foregroundColor(getLineColor(line: line, time: 2000000000))
            }
            Image(systemName: "tram.fill")
                .font(.subheadline)
                .foregroundColor(.white)
        }
    }
}

struct TrainDot_Previews: PreviewProvider {
    static var previews: some View {
        TrainDot(line: "N")
            .previewLayout(.fixed(width: 30, height:50))
    }
}
