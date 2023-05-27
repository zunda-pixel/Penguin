//
//  MediasView.swift
//

import Sweet
import SwiftUI

struct MediasView: View {
  let medias: [Sweet.MediaModel]

  @State var selectedMedia: Sweet.MediaModel?

  func singleMediaView(media: Sweet.MediaModel) -> some View {
    MediaView(media: media, selectedMedia: $selectedMedia)
      .cornerRadius(15)
      .scaledToFit()
      .ifElse(media.size!.width > media.size!.height) {
        $0.frame(maxWidth: 400)
      } elseTransform: {
        $0.frame(maxHeight: 400)
      }
  }
  
  @ViewBuilder
  func mediaView(media: Sweet.MediaModel) -> some View {
    GeometryReader { reader in
      MediaView(
        media: media,
        selectedMedia: $selectedMedia
      )
      .aspectRatio(contentMode: .fill)
      .frame(maxWidth: reader.size.width, maxHeight: reader.size.width)
      .clipped()
    }
    .aspectRatio(1, contentMode: .fit)
    .cornerRadius(15)
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
