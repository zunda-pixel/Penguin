//
//  ScrollImagesView.swift
//

import Sweet
import SwiftUI

struct ScrollImagesView: View {
  let medias: [Sweet.MediaModel]

  @State var selectedMedia: Sweet.MediaModel
  @Environment(\.dismiss) var dismiss

  var body: some View {
    ZStack {
      Color.black
        .ignoresSafeArea()
      TabView(selection: $selectedMedia) {
        ForEach(medias) { media in
          let mediaURL = media.url ?? media.previewImageURL!

          ScalableImage(mediaURL: mediaURL)
          .tag(media)
        }
      }
      #if !os(macOS)
        .tabViewStyle(.page)
      #endif
    }
  }
}
