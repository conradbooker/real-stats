//
//  Color.swift
//  Service Bandage
//
//  Created by Conrad on 2/12/24.
//

import Foundation
import SwiftUI

enum bgColor {
    case first
    case second
    case third
    case fourth
    case fifth

    var value: Color {
        switch self {
        case .first:
            return Color("cDarkGray")
        case .second:
            return Color("cLessDarkGray")
        case .third:
            return Color("cMediumGray")
        case .fourth:
            return Color("cMediumLightGray")
        case .fifth:
            return Color("cOpaqueGray")
        }
    }

}
