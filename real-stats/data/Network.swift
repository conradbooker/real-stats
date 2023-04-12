//
//  Network.swift
//  real-stats
//
//  Created by Conrad on 4/8/23.
//

import Foundation
import SwiftUI
import Network

final class Network: ObservableObject {
    let monitor = NWPathMonitor()
    let queue = DispatchQueue(label: "Monitor")
     
    @Published var isConnected = false
     
    init() {
        monitor.pathUpdateHandler =  { [weak self] path in
            DispatchQueue.main.async {
                self?.isConnected = path.status == .satisfied ? true : false
            }
        }
        monitor.start(queue: queue)
    }
}

func hasNetwork() -> Bool {
    @ObservedObject var monitor = Network()
    
    if monitor.isConnected {
        return true
    }
    return false
}