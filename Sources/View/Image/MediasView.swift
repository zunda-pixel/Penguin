//
//  MediasView.swift
//

import AVKit
import Kingfisher
import Sweet
import SwiftUI

struct MediasView: View {
  let medias: [Sweet.MediaModel]

  @State var selectedMedia: Sweet.MediaModel
  @State var isPresentedImageView = false
  @State var isPresentedVideoPlayer = false

  init(medias: [Sweet.MediaModel]) {
    self.medias = medias
    let media = medias.first!
    self._selectedMedia = .init(wrappedValue: media)
  }

  var body: some View {
    if let videoMedia = medias.first(where: { $0.previewImageURL != nil }) {
      MediaView(mediaURL: videoMedia.previewImageURL!)
        .overlay(alignment: .bottomTrailing) {
          // Gifの場合viewCountが取得できない
          if let viewCount = videoMedia.metrics?.viewCount {
            Text("\(viewCount) count")
              .padding(.horizontal)
              .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 17))
              .padding()
          }
        }
        .onTapGesture {
          isPresentedVideoPlayer.toggle()
        }
        .fullScreenCover(isPresented: $isPresentedVideoPlayer) {
          let url = videoMedia.variants.first { $0.contentType == .mp4 }!.url

          let player = AVPlayer(url: url)
          MoviePlayer(player: player)
            .ignoresSafeArea()
            .onAppear {
              player.play()
            }
        }
    } else {
      LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: medias.count)) {
        ForEach(medias.filter { $0.url != nil }) { media in
          MediaView(mediaURL: media.url!)
            .onTapGesture {
              selectedMedia = media
              isPresentedImageView.toggle()
            }
        }
      }
      .fullScreenCover(isPresented: $isPresentedImageView) {
        ScrollImagesView(medias: medias, selectedMedia: $selectedMedia)
      }
    }
  }
}

struct MediaView: View {
  let mediaURL: URL

  var body: some View {
    KFImage(mediaURL)
      .placeholder { p in
        ProgressView(p)
      }
      .resizable()
      .scaledToFit()
      .clipped()
      .contentShape(Rectangle())
  }
}

struct MediasView_Previews: PreviewProvider {
  static var previews: some View {
    let media1: Sweet.MediaModel = .init(key: "key1", type: .photo, size: .init(width: 100, height: 100), url: .init(string: "https://pbs.twimg.com/media/Fh9TFoFWIAATrnU?format=jpg&name=large")!)
    let media2: Sweet.MediaModel = .init(key: "key2", type: .photo, size: .init(width: 100, height: 100), url: .init(string: "https://pbs.twimg.com/media/Fh2wpusacAAUmac?format=png&name=900x900")!)
    let media3: Sweet.MediaModel = .init(key: "key3", type: .photo, size: .init(width: 100, height: 100), url: .init(string: "https://pbs.twimg.com/media/Fh9TFoFWIAATrnU?format=jpg&name=large")!)
    let media4: Sweet.MediaModel = .init(key: "key4", type: .photo, size: .init(width: 100, height: 100), url: .init(string: "https://pbs.twimg.com/media/Fh9TFoFWIAATrnU?format=jpg&name=large")!)
    MediasView(medias: [media1, media2, media3, media4])
  }
}
