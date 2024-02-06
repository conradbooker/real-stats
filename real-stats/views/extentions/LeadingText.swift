//
//  LeadingText.swift
//  Service Bandage
//
//  Created by Conrad on 1/20/24.
//

import SwiftUI

struct LeadingText: View {
    var text: String
    var padding: CGFloat
    var body: some View {
        HStack {
            Text(text)
                .padding(.leading, padding)
            Spacer()
        }
    }
}

struct LeadingText_Previews: PreviewProvider {
    static var previews: some View {
        LeadingText(text: "hello", padding: 12)
    }
}
