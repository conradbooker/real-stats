//
//  SplashScreen.swift
//  Service Bandage
//
//  Created by Conrad on 8/13/23.
//

import SwiftUI

struct SplashScreen: View {
    @State var isActive: Bool = false
    @State private var size = 0.8
    @State private var opacity = 0.5
    @State private var done: Bool = false
    
    @Environment(\.managedObjectContext) private var viewContext
    let persistentContainer = CoreDataManager.shared.persistentContainer
    @EnvironmentObject var locationViewModel: LocationViewModel

    var body: some View {
        if isActive {
            BottomSheet()
                .environment(\.managedObjectContext, persistentContainer.viewContext)
                .environmentObject(locationViewModel)
        } else {
            ZStack {
                Color("cDarkGray")
                    .ignoresSafeArea()
                VStack {
                    VStack {
                        Image("iconA")
                            .resizable()
                            .frame(width: 200, height: 200)
                            .clipShape(RoundedRectangle(cornerRadius: 50))
                            .shadow(radius: 10)
                        
                        Text("hey!")
                            .font(.title)
                            .fontWeight(.heavy)
                    }
                    .scaleEffect(size)
                    .opacity(opacity)
                    .onAppear {
                        withAnimation(.easeIn(duration: 1.2)) {
                            self.size = 0.9
                            self.opacity = 1.00
                        }
                    }
                }
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        withAnimation {
                            self.isActive = true
                        }
                    }
                }
            }
        }
    }
}

struct SSplashScreen_Previews: PreviewProvider {
    static var previews: some View {
        SplashScreen()
    }
}
