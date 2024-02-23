//
//  MapHelper.swift
//  Service Bandage
//
//  Created by Conrad on 2/20/24.
//

import Foundation
import SwiftUI

struct MapStation: Hashable, Codable, Identifiable {
    var id = UUID()
    var complex: String
    var chosenStation: Int
}
