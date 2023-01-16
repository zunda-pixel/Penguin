//
//  ScalableImage.swift
//

import Kingfisher
import SwiftUI

struct ScalableImage: View {
  let mediaURL: URL
  @Environment(\.dismiss) var dismiss

  @State var lastDragPosition: DragGesture.Value?
  @State var scale: Double = 1
  @State var location: CGPoint

  @MainActor init(mediaURL: URL) {
    self.mediaURL = mediaURL
    self._location = .init(wrappedValue: UIScreen.main.bounds.size.center)
  }

  func resetScale() {
    withAnimation(.easeInOut) {
      scale = 1
    }
  }

  func maxScale() {
    withAnimation(.easeInOut) {
      scale = 2
    }
  }

  @MainActor func resetLocation() {
    withAnimation(.easeInOut) {
      location = UIScreen.main.bounds.size.center
    }
  }

  var body: some View {
    let magnification = MagnificationGesture()
      .onChanged { value in
        let diff = abs(scale - value)

        let direction = scale > value

        let adjustedDiff = (direction ? -diff : diff) / 2

        let scale = scale + adjustedDiff

        if 0 < scale && scale < 3 {
          self.scale = scale
        }
      }
      .onEnded { value in
        if value < 1 {
          resetScale()
        } else if value > 2 {
          maxScale()
        }
      }
    let drag = DragGesture()
      .onChanged { value in
        lastDragPosition = value
        location = value.location
      }
      .onEnded { value in
        let timeDiff = value.time.timeIntervalSince(lastDragPosition!.time)
        let speed: CGFloat =
          CGFloat(value.translation.height - lastDragPosition!.translation.height)
          / CGFloat(timeDiff)

        if abs(speed) > 400 {
          dismiss()
        } else {
          resetLocation()
        }
      }

    ZStack {
      Color.black.ignoresSafeArea()
      KFImage(mediaURL)
        .resizable()
        .padding()
        .scaledToFit()
        .scaleEffect(scale)
        .padding(.horizontal)
        .position(location)
        .gesture(drag)
        .onTapGesture(count: 2) {
          resetScale()
        }
    }
    .gesture(magnification)
    .onTapGesture(count: 1) {
      dismiss()
    }
  }
}

struct ScalableImage_Previews: PreviewProvider {
  static var previews: some View {
    ScalableImage(mediaURL: URL(string: "https://pbs.twimg.com/media/Fh9TFoFWIAATrnU?format=jpg&name=large")!)
  }
}
