//
//  MediasView.swift
//

import Sweet
import SwiftUI

struct MediasView: View {
  let medias: [Sweet.MediaModel]

  @State var selectedMedia: Sweet.MediaModel?

  func singleMediaView(media: Sweet.MediaModel) -> some View {
    GeometryReader { reader in
      MediaView(media: media, selectedMedia: $selectedMedia)
        .frame(
          width: reader.size.width,
          height: reader.size.width * media.size!.height / media.size!.width
        )
    }
    .aspectRatio(
      media.size!.width / media.size!.height,
      contentMode: .fit
    )
  }
  
  @ViewBuilder
  func mediaView(media: Sweet.MediaModel) -> some View {
    GeometryReader { reader in
      MediaView(
        media: media,
        selectedMedia: $selectedMedia
      )
      .aspectRatio(contentMode: .fill)
      .frame(
        width: reader.size.width,
        height: reader.size.width
      )
      .clipped()
    }
    .aspectRatio(1, contentMode: .fit)
  }
  
  @ViewBuilder
  var multipleMediaView: some View {
    let columnCount = medias.count < 3 ? medias.count : 2

    LazyVGrid(
      columns: .init(repeating: GridItem(.flexible(maximum: 400)), count: columnCount),
      alignment: .leading
    ) {
      ForEach(medias) { media in
        mediaView(media: media)
        .cornerRadius(15)
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
  }
  
  var body: some View {
    Group {
      if medias.count == 1 {
        singleMediaView(media: medias.first!)
          .cornerRadius(15)
      }
      else {
        multipleMediaView
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
      key: "key1", type: .photo, size: .init(width: 100, height: 150),
      url: .init(string: "https://pbs.twimg.com/media/FxJWdukakAETlUE?format=png&name=small")!)
    let media2: Sweet.MediaModel = .init(
      key: "key2", type: .photo, size: .init(width: 100, height: 100),
      url: .init(string: "https://pbs.twimg.com/media/Fh2wpusacAAUmac?format=png&name=900x900")!)
    let media3: Sweet.MediaModel = .init(
      key: "key3", type: .photo, size: .init(width: 100, height: 100),
      url: .init(string: "https://pbs.twimg.com/media/Fh9TFoFWIAATrnU?format=jpg&name=large")!)
    let media4: Sweet.MediaModel = .init(
      key: "key4", type: .photo, size: .init(width: 100, height: 100),
      url: .init(string: "https://pbs.twimg.com/media/FxJWlFmacAE_Q-2?format=png&name=small")!)
    List {
      MediasView(medias: [media1, media2, media3, media4])
    }
  }
}
