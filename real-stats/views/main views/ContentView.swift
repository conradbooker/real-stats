//
//  ContentView.swift
//  real-stats
//
//  Created by Conrad on 6/11/23.
//

import SwiftUI
import CoreLocation

struct ContentView: View {
    
    @Environment(\.managedObjectContext) private var viewContext
    let persistedContainer = CoreDataManager.shared.persistentContainer
    @EnvironmentObject var locationViewModel: LocationViewModel
    var coordinate: CLLocationCoordinate2D? {
        locationViewModel.lastSeenLocation?.coordinate
    }
    
    
    //var station: Station
    @State var offset: CGFloat = -100
    @State var lastOffset: CGFloat = -600
    @State var initOffset = 0
    @GestureState var gestureOffset: CGFloat = 0

    var body: some View {
        ZStack {
            
            GeometryReader { proxy in
                let height = proxy.frame(in: .global).height
                let width = proxy.frame(in: .global).width

                MapView()
                    .environment(\.managedObjectContext, CoreDataManager.shared.persistentContainer.viewContext)
                    .environmentObject(LocationViewModel())
            }
            
            GeometryReader { proxy -> AnyView in
                
                let height = proxy.frame(in: .global).height
                let width = proxy.frame(in: .global).width
                //offset = -((height - 100) / 3) - 200
                
                return AnyView (
                    ZStack {
                        Home()
                            .environment(\.managedObjectContext, CoreDataManager.shared.persistentContainer.viewContext)
                            .environmentObject(LocationViewModel())
                            .clipShape(RoundedRectangle(cornerSize: CGSize(width: 10, height: 10)))
                            .shadow(radius: 2)
                            .onTapGesture {
                                withAnimation(.linear(duration: 0.25)) {
                                    offset = -600
                                }
                            }
                    }
                        .offset(y: height - 100)
                        .offset(y: offset)
                        .gesture(DragGesture().updating($gestureOffset, body: {
                            value, out, _ in
                            out = value.translation.height
                            onChange()
                        }).onEnded({ value in
                            let maxHeight = height - 100 - 60
                            withAnimation{
                                if -offset > maxHeight {
                                    offset = -maxHeight
                                } else if -offset < 100 && initOffset == 0 {
                                    initOffset = 1
                                    offset = -500
                                } else if -offset < 100 && initOffset == 1 {
                                    offset = -100
                                }
                            }
                            lastOffset = offset
                        }))
                )
            }
            .ignoresSafeArea(.all, edges: .bottom)
        }
        .environment(\.managedObjectContext, CoreDataManager.shared.persistentContainer.viewContext)
        .environmentObject(LocationViewModel())
    }
    
    func onChange() {
        DispatchQueue.main.async {
            self.offset = gestureOffset + lastOffset
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    let persistentContainer = CoreDataManager.shared.persistentContainer

    static var previews: some View {
        ContentView()
            .environment(\.managedObjectContext, CoreDataManager.shared.persistentContainer.viewContext)
            .environmentObject(LocationViewModel())
    }
}
