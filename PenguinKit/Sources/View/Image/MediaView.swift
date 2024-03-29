//
//  MediaView.swift
//

import AVKit
import Kingfisher
import Sweet
import SwiftUI

struct MediaView: View {
  let media: Sweet.MediaModel

  @State var isPresentedVideoPlayer: Bool = false
  @Binding var selectedMedia: Sweet.MediaModel?

  func videoImage(url: URL) -> some View {
    KFImage(url)
    .resizable()
    .placeholder { p in
      Rectangle()
      .fill(.secondary)
      .overlay {
        ProgressView(p)
      }
    }
    .overlay {
      Image(systemName: "play.circle")
        .imageScale(.large)
    }
    .onTapGesture {
      isPresentedVideoPlayer.toggle()
    }
    #if os(macOS)
      .sheet(isPresented: $isPresentedVideoPlayer) {
        let url = media.variants.last { $0.contentType == .mp4 }!.url

        MoviePlayer(url: url)
        .ignoresSafeArea()
      }
    #else
      .fullScreenCover(isPresented: $isPresentedVideoPlayer) {
        let url = media.variants.last { $0.contentType == .mp4 }!.url

        MoviePlayer(url: url)
        .ignoresSafeArea()
      }
    #endif

  }

  func image(url: URL) -> some View {
    KFImage(url)
      .resizable()
      .placeholder { p in
        Rectangle()
          .fill(.secondary)
          .overlay {
            ProgressView(p)
          }
      }
      .onTapGesture {
        selectedMedia = media
      }
  }

  var body: some View {
    switch media.mediaType {
    case .image(let url):
      image(url: url)
    case .video(let url):
      videoImage(url: url)
    }
  }
}

struct MediaView_Previews: PreviewProvider {
  struct Preview: View {
    let media: Sweet.MediaModel
    @State var selectedMedia: Sweet.MediaModel?

    init() {
      let media = Sweet.MediaModel(
        key: "key1",
        type: .photo,
        size: .init(width: 100, height: 100),
        url: .init(string: "https://pbs.twimg.com/media/Fh9TFoFWIAATrnU?format=jpg&name=large")!
      )

      self.media = media
    }

    var body: some View {
      MediaView(
        media: media,
        selectedMedia: $selectedMedia
      )
    }
  }

  static var previews: some View {
    Preview()
  }
}

extension Sweet.MediaModel {
  enum MediaType {
    case video(url: URL)
    case image(url: URL)
  }

  var mediaType: MediaType {
    if let previewImageURL {
      return .video(url: previewImageURL)
    }

    if let url {
      return .image(url: url)
    }

    fatalError()
  }
}
