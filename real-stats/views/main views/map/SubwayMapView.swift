//
//  SubwayMapView.swift
//  Service Bandage
//
//  Created by Conrad on 6/18/23.
//

import SwiftUI
import UIKit

struct ZoomableScrollView<Content: View>: UIViewRepresentable {
  private var content: Content

  init(@ViewBuilder content: () -> Content) {
    self.content = content()
  }

  func makeUIView(context: Context) -> UIScrollView {
    // set up the UIScrollView
    let scrollView = UIScrollView()
    scrollView.delegate = context.coordinator  // for viewForZooming(in:)
    scrollView.maximumZoomScale = 20
    scrollView.minimumZoomScale = 1
    scrollView.bouncesZoom = true

    // create a UIHostingController to hold our SwiftUI content
    let hostedView = context.coordinator.hostingController.view!
    hostedView.translatesAutoresizingMaskIntoConstraints = true
    hostedView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    hostedView.frame = scrollView.bounds
    scrollView.addSubview(hostedView)

    return scrollView
  }

  func makeCoordinator() -> Coordinator {
    return Coordinator(hostingController: UIHostingController(rootView: self.content))
  }

  func updateUIView(_ uiView: UIScrollView, context: Context) {
    // update the hosting controller's SwiftUI content
    context.coordinator.hostingController.rootView = self.content
    assert(context.coordinator.hostingController.view.superview == uiView)
  }

  // MARK: - Coordinator

  class Coordinator: NSObject, UIScrollViewDelegate {
    var hostingController: UIHostingController<Content>

    init(hostingController: UIHostingController<Content>) {
      self.hostingController = hostingController
    }

    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
      return hostingController.view
    }
  }
}


struct SubwayMapView: View {
    // 11700 × 14244
    @State private var scale: CGFloat = 5
    var body: some View {
        ZoomableScrollView {
            Image("mapPilot")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 11700/scale, height: 14244/scale)
        }
//        ScrollView([.vertical,.horizontal], showsIndicators: false) {
//            Image("mapPilot")
//                .resizable()
//                .aspectRatio(contentMode: .fit)
//                .frame(width: 11700/scale, height: 14244/scale)
//        }
    }
}

struct SubwayMapView_Previews: PreviewProvider {
    static var previews: some View {
        SubwayMapView()
    }
}
