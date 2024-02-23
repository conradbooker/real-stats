//
//  SubwayMapView.swift
//  Service Bandage
//
//  Created by Conrad on 6/18/23.
//

import SwiftUI
import SVGView

extension UIScreen {
    static var topSafeArea: CGFloat {
        let keyWindow = UIApplication.shared.connectedScenes
            .filter({$0.activationState == .foregroundActive})
            .map({$0 as? UIWindowScene})
            .compactMap({$0})
            .first?.windows
            .filter({$0.isKeyWindow}).first
        
        return (keyWindow?.safeAreaInsets.top) ?? 0
    }
}

struct ZoomableScrollView<Content: View>: UIViewRepresentable {
    @Binding var inited: Bool
    @Binding var settingPosition: Bool
    var contentOffset: CGPoint
    private var content: Content
    
    @AppStorage("xOffset") var xOffset: Double = 0
    @AppStorage("yOffset") var yOffset: Double = 0
    @AppStorage("zoom") var zoom: Double = 0

    init(inited: Binding<Bool>, contentOffset: CGPoint, settingPosition: Binding<Bool>, @ViewBuilder content: () -> Content) {

        self.content = content()
        self._inited = inited
//        self.xOffset = xOffset
//        self.yOffset = yOffset
        self.contentOffset = contentOffset
        self._settingPosition = settingPosition
    }
    

    func makeUIView(context: Context) -> UIScrollView {
        // set up the UIScrollView
        let scrollView = UIScrollView()
        
        
        scrollView.delegate = context.coordinator  // for viewForZooming(in:)
        scrollView.maximumZoomScale = 20
        scrollView.minimumZoomScale = 3
        scrollView.bouncesZoom = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        
        scrollView.contentInsetAdjustmentBehavior = .never
        scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: -1062 /* ends in 95*/, right: 0)
//        scrollView.setContentOffset(CGPoint(x: 200, y: 200), animated: true)
//        scrollView.contentInset = UIEdgeInsets(top: 100, left: 0, bottom: 0, right: 0)
        DispatchQueue.main.async {
            if !inited {
                scrollView.setZoomScale(zoom, animated: true)
                inited = true
            }
        }

        // create a UIHostingController to hold our SwiftUI content
        let hostedView = context.coordinator.hostingController.view!
        hostedView.translatesAutoresizingMaskIntoConstraints = true
        hostedView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        hostedView.frame = scrollView.bounds
        scrollView.addSubview(hostedView)
        
//        scrollView.zoomScale = 8

        return scrollView
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(hostingController: UIHostingController(rootView: self.content), parent: self)
    }

    func updateUIView(_ uiView: UIScrollView, context: Context) {
        // update the hosting controller's SwiftUI content
        context.coordinator.hostingController.rootView = self.content
        print("UIVIEW x: \(uiView.contentOffset.x), y: \(uiView.contentOffset.y)")
        
//        if !inited {
//            uiView.setContentOffset(contentOffset, animated: false)
//        }
        
        assert(context.coordinator.hostingController.view.superview == uiView)
    }

    // MARK: - Coordinator

    class Coordinator: NSObject, UIScrollViewDelegate {
        var hostingController: UIHostingController<Content>
        
        let parent: ZoomableScrollView

        init(hostingController: UIHostingController<Content>, parent: ZoomableScrollView) {
            self.hostingController = hostingController
            self.parent = parent
        }
        
        func scrollViewDidScroll(_ scrollView: UIScrollView) {
            let offset = scrollView.contentOffset

            if parent.settingPosition {
                scrollView.contentOffset = self.parent.contentOffset
                self.parent.settingPosition = false
            }
            
            print("Relative content offset: x:\(offset.x/scrollView.zoomScale), y:\(offset.y/scrollView.zoomScale)")
            print("Content offset: x:\(offset.x), y:\(offset.y)")
            parent.xOffset = offset.x
            parent.yOffset = offset.y
        }
        
        func scrollViewDidZoom(_ scrollView: UIScrollView) {
            parent.zoom = scrollView.zoomScale
//            print("Zoom: \(scrollView.zoomScale)")
        }

        func viewForZooming(in scrollView: UIScrollView) -> UIView? {
            return hostingController.view
        }
    }
}

struct StationButton: View {
    var x: CGFloat
    var y: CGFloat
    var station: String
    var body: some View {
        Button {
            
        } label: {
            Image(systemName: "trash")
                .resizable()
                .frame(width: 2,height: 2)
        }
        .offset(x: 100, y:100)
    }
}

@available(iOS 16.0, *)
struct Ugh: View {
    @State var inited = false
    @State var contentOffset = CGPoint(x: 0, y: 0)
    @State var settingPosition = false
    
    @AppStorage("xOffset") var xOffset: Double = 0
    @AppStorage("yOffset") var yOffset: Double = 0
    @AppStorage("zoom") var zoom: Double = 0
    
    @State private var tappedOffset: CGPoint? = nil
    @State private var i: Int = 410
    @State private var j: Int = 0
    // 'i' NEEDS TO BE CHANGED TO @APPSTORAGE
    
    @State var currentShape = "circle"
    @State var rotation = 0
    
    @AppStorage("stationLocations") var stationLocations = ""

    var body: some View {
        ZStack {
            VStack {
                GeometryReader { geometry in
                    ZStack {
                        ZoomableScrollView(inited: $inited, contentOffset: contentOffset, settingPosition: $settingPosition) {
                            ZStack {
                                Image("myMap")
//                                SVGView(contentsOf: Bundle.main.url(forResource: "myMap", withExtension: "svg")!)
                                    .resizable()
                                    .frame(width: geometry.size.width, height: geometry.size.width * 1.217)
                                    .onAppear {
                                        contentOffset = CGPoint(x: xOffset, y: yOffset)
                                        settingPosition = true
                                    }
                                    .onTapGesture { tapLocation in
                                        // Calculate tap offset relative to the image's coordinate system
                                        let x = tapLocation.x - geometry.frame(in: .global).minX
                                        let y = tapLocation.y - geometry.frame(in: .global).minY + 413.4
                                        let tappedPoint = CGPoint(x: x, y: y)
                                        self.tappedOffset = tappedPoint
                                        print("TAPPED x: \(tappedOffset?.x ?? 0), y: \((tappedOffset?.y ?? 0) - 413.4)")
                                        
                                        if j < complexData[i].stations.count-1 {
                                            j += 1
                                        } else {
                                            i += 1
                                            j = 0
                                        }
                                    }
                                    
                                
                                VStack {
                                    Button {
                                        contentOffset = CGPoint(x: 0, y: 0)
                                        settingPosition = true
                                        print("hi")
                                    } label: {
                                        Image(systemName: "trash")
                                            .resizable()
                                            .frame(width: 5,height: 5)
                                    }
                                    .position(x: (tappedOffset?.x ?? 0), y: (tappedOffset?.y ?? 0))
                                }
                            }
//                            .border(.red)
                            .padding(.top,-393.4 + geometry.safeAreaInsets.top)
                            //                    .padding(.bottom,-500)
                        }
                        .ignoresSafeArea(.all)
                        VStack {
                            Rectangle()
                                .frame(height: geometry.safeAreaInsets.top)
                                .background(.ultraThinMaterial)
                                .environment(\.colorScheme, .dark)
                            //                        .blur(radius: 0.01)
                            Spacer()
                        }
                        .ignoresSafeArea(.all)
                    }
                }
            }
            ZStack {
                VStack {
                    Rectangle()
                        .frame(height: 100)
                        .foregroundColor(.white)
                        .onTapGesture {
                            if j > 0 {
                                j -= 1
                            } else {
                                i -= 1
                            }
                        }
                    Spacer()
                }
                VStack {
                    Text("\(i)")
                    Text(complexData[i].complexName)
                    Text(complexData[i].stations[j].GTFSID)
                    Text(complexData[i].stations[j].stopName)
                    Spacer()
                }
                /*
                 Controls here:
                    station shape -- circle, horizontal
                    station angle
                    radius / size
                 Iterates through the station data
                1: circle, 2: rectangle
                1: 0: 0 deg, 1: 45 deg...
                 ["G01", [46.6941, 23.1898],[1,4]],
                 ["G01", [21.4123, 53.1581]],
                 ["G01", [48.1283, 73.5182]] --> stored in the app defaults
                 IF MADE MISTAKE: remove 29 characters (the ammount to delete the most simple) -- if the 3 characters at end of new string are not ']],' --> removeLast(1)
                 
                
                 */
            }
        }
    }
}

struct Ugh_Previews: PreviewProvider {
    static var previews: some View {
        if #available(iOS 16.0, *) {
            Ugh()
        } else {
            Text("hi")
        }
    }
}
