//
// OGPCardView.swift
//

import Kingfisher
import SwiftUI
import os

struct OGPCardView: View {
  @StateObject var viewModel: OGPCardViewModel

  @Environment(\.openURL) var openURL
  @Environment(\.settings) var settings

  var body: some View {
    VStack {
      if let imageURL = viewModel.ogp?.imageURL {
        VStack(alignment: .leading) {
          KFImage(imageURL)
            .resizable()
            .scaledToFit()

          Text(viewModel.url.host!)
            .foregroundStyle(settings.colorType.colorSet.tintColor)

          if let title = viewModel.ogp?.title?.removingHTMLEntities() {
            Text(title)
              .lineLimit(2)
          }

          if let description = viewModel.ogp?.description?.removingHTMLEntities() {
            Text(description)
              .foregroundStyle(.secondary)
              .font(.caption)
              .lineLimit(2)
          }

        }
        .padding(3)
        .border(.secondary, width: 3)
        .contentShape(Rectangle())
        .onTapGesture {
          openURL(viewModel.url)
        }
      }
    }
    .alert(errorHandle: $viewModel.errorHandle)
    .task {
      await viewModel.fetchOGP()
    }
  }
}

struct OGPCardView_Previews: PreviewProvider {
  static var previews: some View {
    let viewModel: OGPCardViewModel = .init(
      url: .init(string: "https://cssnite.doorkeeper.jp/events/141697")!)

    OGPCardView(viewModel: viewModel)
  }
}
