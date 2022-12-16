//
//  Photo.swift
//

import Foundation
import Photos

struct Photo: Identifiable {
  let id: String?
  let item: PhotoData
}

enum PhotoData {
  case livePhoto(livePhoto: PHLivePhoto)
  case movie(movie: Movie)
  case photo(photo: ImageData)
}
