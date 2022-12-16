//
//  PhotosPickerItem+Extension.swift
//

import PhotosUI
import SwiftUI

#if os(macOS)
  typealias ImageData = NSImage
#else
  typealias ImageData = UIImage
#endif

extension PhotosPickerItem {
  func loadPhoto() async throws -> PhotoData {
    if let livePhoto = try await self.loadTransferable(type: PHLivePhoto.self) {
      return .livePhoto(livePhoto: livePhoto)
    } else if let movie = try await self.loadTransferable(type: Movie.self) {
      return .movie(movie: movie)
    } else if let data = try await self.loadTransferable(type: Data.self) {
      if let image: ImageData = .init(data: data) {
        return .photo(photo: image)
      }
    }

    fatalError()
  }
}
