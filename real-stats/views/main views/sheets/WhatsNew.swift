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
//                    Spacer()
                    Image("N")
                        .resizable()
                        .frame(width: 50,height: 50)
                    Image("E")
                        .resizable()
                        .frame(width: 50,height: 50)
                    Image("W")
                        .resizable()
                        .frame(width: 50,height: 50)
                    Spacer()
                    Image("M")
                        .resizable()
                        .frame(width: 50,height: 50)
                    Image("A")
                        .resizable()
                        .frame(width: 50,height: 50)
                    Image("JSQ_33")
                        .resizable()
                        .frame(width: 50,height: 50)
//                    Spacer()
                }
                .padding()
                .frame(width: UIScreen.screenWidth)
                VStack(alignment: .leading, spacing: 10) {
                    Text("Significantly Improved Speed of UI")
                    Text("Added Diagramic Map - Light Mode and Dark Mode")
                    Text("Fixed Light Mode and Dark Mode Settings")
                    Text("Added option to sort departure view by track (on by default)")
                    Text("Other bug fixes (as per usual)")
                }.padding(.leading)
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
