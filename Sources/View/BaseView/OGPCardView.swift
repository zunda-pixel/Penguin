//
// OGPCardView.swift
//

import Kingfisher
import SwiftUI

struct OGPCardView: View {
  @StateObject var viewModel: OGPCardViewModel

  @Environment(\.openURL) var openURL
  @Environment(\.settings) var settings

  var body: some View {
    VStack {
      let padding: CGFloat = 20

      if let imageURL = viewModel.ogp?.imageURL {
        VStack(alignment: .leading) {
          KFImage(imageURL)
            .resizable()
            .scaledToFit()


          VStack {
            Text(viewModel.url.host!)
              .foregroundStyle(settings.colorType.colorSet.tintColor)
            
            // ToDo なぜか2回removingHTMLEntities()しないと識字可能な文字にならない
            if let title = viewModel.ogp?.title?.removingHTMLEntities().removingHTMLEntities() {
              Text(title)
                .lineLimit(2)
            }
            
            if let description = viewModel.ogp?.description?.removingHTMLEntities() {
              Text(description.removingHTMLEntities())
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
