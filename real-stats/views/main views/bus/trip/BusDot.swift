//
//  BusDot.swift
//  Service Bandage
//
//  Created by Conrad on 2/4/24.
//

import SwiftUI

struct BusDot: View {
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
                    .foregroundColor(getLineColor_Bus(line: line, time: 2000000000))
            }
            Image(systemName: "bus.fill")
                .font(.subheadline)
                .foregroundColor(.white)
        }
    }
}

struct BusDot_Previews: PreviewProvider {
    static var previews: some View {
        BusDot(line: "A")
    }
}
