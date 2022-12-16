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
      Text(movie.url.absoluteString)
    case .photo(let photo):
      Image(image: photo)
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
