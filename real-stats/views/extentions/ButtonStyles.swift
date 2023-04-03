//
//  ButtonStyles.swift
//  real-stats
//
//  Created by Conrad on 3/31/23.
//

import Foundation
import SwiftUI

struct CButton: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.9 : 1)
    }
}
