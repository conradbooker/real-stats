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
                    Image("BUS")
                        .resizable()
                        .frame(width: 100,height: 50)
                    Spacer()
                }
                .padding()
                Text("Added Bus Support!!")
                Text("New and revised UI")
                Text("Fixed various station naming")
                Text("Fixed that really annoying offset tap thing")
                Text("Bug fixes")
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

struct WhatsNew_Previews: PreviewProvider {
    static var previews: some View {
        WhatsNew()
    }
}
