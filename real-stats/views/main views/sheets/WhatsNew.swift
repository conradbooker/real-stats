//
//  WhatsNew.swift
//  Service Bandage
//
//  Created by Conrad on 8/27/23.
//

import SwiftUI

struct WhatsNew: View {
    let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack {
            Text(String(format: NSLocalizedString("whats-new", comment: ""), appVersion ?? ""))
                .font(.title)
                .fontWeight(.bold)
                .padding()
            VStack(alignment: .leading,spacing: 10) {
                HStack(spacing: 10) {
                    Spacer()
                    Image("SI")
                        .resizable()
                        .frame(width: 50,height: 50)
                    Image("PATH")
                        .resizable()
                        .frame(width: 100,height: 50)
                    Spacer()
                }
                .padding()
                Text("Added Staten Island Railway, and PATH Support (BETA)")
                Text("Added refresh button for stations")
                Text("Fixed various station naming")
            }
            Spacer()
            Button {
                dismiss()
            } label: {
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .frame(width: UIScreen.screenWidth-50,height: 70)
                    Text("Continue")
                        .foregroundColor(.white)
                        .font(.title3)
                }
            }
            .padding()
//                .
        }
        .padding()
        .frame(width: UIScreen.screenWidth)
        .interactiveDismissDisabled()
    }
}

//#Preview {
//    WhatsNew()
//}
