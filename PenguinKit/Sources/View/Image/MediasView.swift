//
//  MediasView.swift
//

import Sweet
import SwiftUI

struct MediasView: View {
  let medias: [Sweet.MediaModel]

  @State var selectedMedia: Sweet.MediaModel?

  init(medias: [Sweet.MediaModel]) {
    self.medias = medias
  }

  var body: some View {
    #if os(macOS)
      let columnCount = medias.count
    #else
      let columnCount = medias.count < 3 ? medias.count : 2
    #endif

    LazyVGrid(columns: .init(repeating: GridItem(.flexible()), count: columnCount)) {
      ForEach(medias) { media in
        GeometryReader { reader in
          MediaView(
            media: media,
            selectedMedia: $selectedMedia
          )
          .scaledToFill()
          .frame(height: reader.size.width)
        }
        .clipped()
        .aspectRatio(1, contentMode: .fit)
        .ifLet(media.metrics?.viewCount) { view, viewCount in
          view.overlay(alignment: .bottomTrailing) {
            Text("\(viewCount) views")
            .font(.caption2)
            .padding(.horizontal, 3)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 3))
            .padding(7)
          }
        }
      }
    }
    #if os(macOS)
      .sheet(item: $selectedMedia) { media in
        ScrollImagesView(
          medias: medias,
          selectedMedia: media
        )
      }
    #else
      .fullScreenCover(item: $selectedMedia) { media in
        ScrollImagesView(
          medias: medias,
          selectedMedia: media
        )
      }
    #endif
  }
}

struct MediasView_Previews: PreviewProvider {
  static var previews: some View {
    let media1: Sweet.MediaModel = .init(
      key: "key1", type: .photo, size: .init(width: 100, height: 100),
      url: .init(string: "https://pbs.twimg.com/media/Fh9TFoFWIAATrnU?format=jpg&name=large")!)
    let media2: Sweet.MediaModel = .init(
      key: "key2", type: .photo, size: .init(width: 100, height: 100),
      url: .init(string: "https://pbs.twimg.com/media/Fh2wpusacAAUmac?format=png&name=900x900")!)
    let media3: Sweet.MediaModel = .init(
      key: "key3", type: .photo, size: .init(width: 100, height: 100),
      url: .init(string: "https://pbs.twimg.com/media/Fh9TFoFWIAATrnU?format=jpg&name=large")!)
    let media4: Sweet.MediaModel = .init(
      key: "key4", type: .photo, size: .init(width: 100, height: 100),
      url: .init(string: "https://pbs.twimg.com/media/Fh9TFoFWIAATrnU?format=jpg&name=large")!)
    MediasView(medias: [media1, media2, media3, media4])  //, media4])
      .frame(width: 300, height: 300)
      .cornerRadius(15)
  }
}
