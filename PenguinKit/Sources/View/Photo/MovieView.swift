//
//  MovieView.swift
//

import SwiftUI
import AVKit

struct MovieView: View {
  let movie: Movie
#if os(macOS)
  @State var thumbnail: NSImage?
#else
  @State var thumbnail: UIImage?
#endif
  
  func generateThumbnail() async -> ImageData {
    let asset = AVAsset(url: movie.url)
    let generator = AVAssetImageGenerator(asset: asset)
    let duration = try! await asset.load(.duration)
    let (image, _) = try! await generator.image(at: duration)
    #if os(macOS)
    return NSImage(cgImage: image, size: .zero)
    #else
    return UIImage(cgImage: image)
    #endif
  }
  
  var body: some View {
    if let thumbnail {
      Image(image: thumbnail)
        .resizable()
    } else {
      ProgressView()
        .task {
          thumbnail = await generateThumbnail()
        }
    }
  }
}
