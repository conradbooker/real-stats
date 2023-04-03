//
//  LineLogo.swift
//  real-stats
//
//  Created by Conrad on 3/30/23.
//

import SwiftUI

struct LineLogo: View {
    var line: String
    var color: Color
    var isDiamond: Bool
    var width: CGFloat
    
    var scale: Double {
        return Double(width/40)
    }
    
    var body: some View {
        if !isDiamond {
            ZStack {
                Circle()
                    .foregroundColor(color)
                    .frame(width: width)
                Text(line)
                    .font(.title)
                    .scaleEffect(scale)
            }
        } else {
            
        }
    }
}

struct LineLogo_Previews: PreviewProvider {
    static var previews: some View {
        LineLogo(line: "6", color: .green, isDiamond: false, width: 30)
    }
}
