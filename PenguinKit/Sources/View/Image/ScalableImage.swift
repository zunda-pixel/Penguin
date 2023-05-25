//
//  ScalableImage.swift
//

import Kingfisher
import SwiftUI

struct ScalableImage: View {
  let mediaURL: URL
  @Environment(\.dismiss) var dismiss

  var body: some View {
    ZStack {
      Color.black.ignoresSafeArea()
      KFImage(mediaURL)
        .resizable()
        .scaledToFit()
    }
    .onTapGesture {
      dismiss()
    }
  }
}

struct ScalableImage_Previews: PreviewProvider {
  static var previews: some View {
    ScalableImage(
      mediaURL: URL(string: "https://pbs.twimg.com/media/Fh9TFoFWIAATrnU?format=jpg&name=large")!)
  }
}
