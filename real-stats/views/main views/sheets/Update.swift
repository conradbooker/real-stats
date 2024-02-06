//
//  Update.swift
//  Service Bandage
//
//  Created by Conrad on 8/27/23.
//

import SwiftUI

class VersionCheck: ObservableObject {
    @Published var isUpdateAvailable = false

    func checkVersion() {
        guard let bundleId = Bundle.main.infoDictionary?["CFBundleIdentifier"] as? String else { return }
        guard let url = URL(string: "https://itunes.apple.com/lookup?bundleId=\(bundleId)") else { return }
            let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let data = data {
                do {
                    let jsonObject = try JSONSerialization.jsonObject(with: data)
                    guard let json = jsonObject as? [String: Any] else {
                        print("The received that is not a Dictionary")
                        return
                    }
                    let results = json["results"] as? [[String: Any]]
                    let firstResult = results?.first
                    let mostRecentVersion = Double((firstResult?["version"] as? String ?? "") ?? "") ?? 0
                    let currentVersion = Double((Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "") ?? "") ?? 0

                    if mostRecentVersion > currentVersion {
                        self.isUpdateAvailable = true
                        print(self.isUpdateAvailable, mostRecentVersion, currentVersion)
                    }
                    print("currentVersion: ", currentVersion ?? "")
                } catch let serializationError {
                    print("Serialization Error: ", serializationError)
                }
            }
        }
        task.resume()
    }
}

struct Update: View {

    var body: some View {
        VStack {
            Text("Sorry for the interruption!")
                .font(.title)
                .fontWeight(.bold)
                .padding()
            VStack(alignment: .leading,spacing: 10) {
                Text("Your current app version is not up to date. Please update Transit Bandage!")
                Text("(It should take less than 30 seconds)")
            }
            Spacer()
            Button {
                if let appStoreURL = URL(string: "https://apps.apple.com/app/transit-bandage/id6461312160") {
                 UIApplication.shared.open(appStoreURL)
                }
            } label: {
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .frame(width: UIScreen.screenWidth-50,height: 70)
                    Text("Update")
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
//    Update()
//}
