//
// OGPCardView.swift
//

import Kingfisher
import Sweet
import SwiftUI

struct OGPCardView: View {
  let urlModel: Sweet.URLModel

  @Environment(\.openURL) var openURL
  @Environment(\.settings) var settings

  var aspectRatio: CGFloat {
    imageURL.size.width / imageURL.size.height
  }
  
  var imageURL: Sweet.ImageModel {
    urlModel.images.max {
      $0.size.height * $0.size.width < $1.size.height * $1.size.width
    }!
  }
  
  var image: some View {
    KFImage(imageURL.url)
      .resizable()
      .placeholder { p in
        Rectangle()
          .fill(.secondary)
          .overlay {
            ProgressView(p)
          }
      }
  }
  
  var landscapeImage: some View {
    GeometryReader { reader in
      image
        .frame(
          width: reader.size.width,
          height: reader.size.width / aspectRatio
        )
    }
    .aspectRatio(aspectRatio, contentMode: .fit)
  }
  
  var portraitImage: some View {
    GeometryReader { reader in
      image
        .aspectRatio(contentMode: .fill)
        .frame(
          width: reader.size.width,
          height: reader.size.width
        )
        .clipped()
    }
    .aspectRatio(1, contentMode: .fit)
  }
  
  var body: some View {
    let padding: CGFloat = 10

    VStack(alignment: .leading) {
      if imageURL.size.height > imageURL.size.width {
        portraitImage
      } else {
        landscapeImage
      }
      
      Group {
        Text(urlModel.displayURL!)
          .foregroundStyle(settings.colorType.colorSet.tintColor)

        if let title = urlModel.title {
          Text(title)
            .lineLimit(2)
        }

        if let description = urlModel.description {
          Text(description)
            .foregroundStyle(.secondary)
            .font(.caption)
            .lineLimit(2)
        }
      }
      .padding(.horizontal, padding)
    }
    .clipShape(RoundedRectangle(cornerSize: .init(width: padding, height: padding)))
    .contentShape(RoundedRectangle(cornerSize: .init(width: padding, height: padding)))
    .overlay {
      RoundedRectangle(cornerSize: .init(width: padding, height: padding))
        .stroke(.secondary)
    }
    .onTapGesture {
      let url: URL = urlModel.expandedURL.map { URL(string: $0) ?? urlModel.url } ?? urlModel.url
      openURL(url)
    }
  }
}

struct OGPCardView_Previews: PreviewProvider {
  static func urlModel(url: URL, size: CGSize) -> Sweet.URLModel {
    Sweet.URLModel(
      url: url,
      start: 0,
      end: 0,
      expandedURL: "",
      displayURL: "displayURL",
      images: [
        .init(
          url: url,
          size: size
        ),
      ],
      title: "Title",
      description: "Description"
    )
  }
  
  static var previews: some View {
    List {
      HStack {
        Image(systemName: "person")
          .frame(width: 30, height: 30)
        
        OGPCardView(urlModel: urlModel(
          url: .init(string: "https://pbs.twimg.com/media/FxJWlFmacAE_Q-2?format=png&name=small")!,
          size: .init(width: 150, height: 300))
        )
      }
      OGPCardView(urlModel: urlModel(
        url: .init(string: "https://pbs.twimg.com/media/FxJWlFmacAE_Q-2?format=png&name=small1")!,
        size: .init(width: 150, height: 300))
      )
      
      OGPCardView(urlModel: urlModel(
        url: .init(string: "https://pbs.twimg.com/media/FxJWlFmacAE_Q-2?format=png&name=small")!,
        size: .init(width: 300, height: 150))
      )
      OGPCardView(urlModel: urlModel(
        url: .init(string: "https://pbs.twimg.com/media/FxJWlFmacAE_Q-2?format=png&name=small1")!,
        size: .init(width: 300, height: 150))
      )
    }
  }
}
