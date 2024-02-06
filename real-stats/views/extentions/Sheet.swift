//
//  Sheet.swift
//  Service Bandage
//
//  Created by Conrad on 2/4/24.
//

import Foundation
import SwiftUI

public struct SyncLayoutOnDissappear: ViewModifier {
    public func body(content: Content) -> some View {
      content
        .onDisappear {
          let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene
          if let viewFrame = scene?.windows.first?.rootViewController?.view.frame {
            scene?.windows.first?.rootViewController?.view.frame = .zero
            scene?.windows.first?.rootViewController?.view.frame = viewFrame
          }
        }
    }
}

public extension View {
    func syncLayoutOnDissappear() -> some View {
      modifier(SyncLayoutOnDissappear())
    }
}
