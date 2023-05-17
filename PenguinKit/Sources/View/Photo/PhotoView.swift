//
//  PhotoView.swift
//

import SwiftUI

struct PhotoView: View {
  let photo: Photo

  var body: some View {
    switch photo.item {
    case .livePhoto(let livePhoto):
      LivePhotoView(livePhoto: livePhoto)
    case .movie(let movie):
      MovieView(movie: movie)
    case .photo(let photo):
      Image(image: photo)
        .resizable()
    }
  }
}

extension Image {
  #if os(macOS)
    init(image: ImageData) {
      self.init(nsImage: image)
    }
  #else
    init(image: ImageData) {
      self.init(uiImage: image)
    }
  #endif
}
