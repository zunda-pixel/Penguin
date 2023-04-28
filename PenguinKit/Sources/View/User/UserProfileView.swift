//
//  UserProfileView.swift
//

import MapKit
import Sweet
import SwiftUI

struct UserProfileView: View {
  @StateObject var viewModel: UserProfileViewModel

  @Environment(\.openURL) var openURL
  @Environment(\.settings) var settings

  var body: some View {
    VStack {
      Text(viewModel.user.name)
        .font(.title)

      Text("@\(viewModel.user.userName)")
        .foregroundColor(.secondary)

      Text(viewModel.user.description!)

      if let url = viewModel.user.url {
        HStack {
          Image(systemName: "link")

          if let urlModel = viewModel.user.entity?.urls.first(where: { $0.url == url }) {
            let displayURL = urlModel.displayURL ?? urlModel.expandedURL ?? url.absoluteString
            let destinationURL: URL = urlModel.expandedURL.map { URL(string: $0) ?? url } ?? url

            Link(displayURL, destination: destinationURL)
          } else {
            Link(url.absoluteString, destination: url)
          }
        }
      }

      HStack {
        Image(systemName: "bird").foregroundColor(settings.colorType.colorSet.tintColor)

        Text(viewModel.user.createdAt!, style: .date)
      }

      if let location = viewModel.user.location {
        HStack {
          if let region = viewModel.region {
            let rectangle = RoundedRectangle(cornerRadius: 10)

            Map(coordinateRegion: .constant(region.boundingRegion))
              .aspectRatio(1, contentMode: .fit)
              .frame(width: 60)
              .clipShape(rectangle)
              .overlay {
                rectangle.stroke(.secondary, lineWidth: 2)
              }

            VStack(alignment: .leading) {
              Text(location)
              if let title = region.mapItems.first?.placemark.title {
                Text(title)
                  .font(.footnote)
                  .lineLimit(2)
                  .foregroundColor(.secondary)
              }
            }
          } else {
            Text("\(Image(systemName: "location")) \(location)")
          }
        }
        .onTapGesture {
          var components: URLComponents = .init(string: "https://maps.apple.com/")!
          components.queryItems = [.init(name: "q", value: location)]
          openURL(components.url!)
        }
        .task {
          await viewModel.fetchRegion(location: location)
        }
      }
    }
  }
}

struct UserProfileView_Previews: PreviewProvider {
  static var previews: some View {
    let viewModel: UserProfileViewModel = .init(
      user: .init(
        id: "3123131", name: "zunda", userName: "zunda_pixel", description: "description",
        createdAt: Date(), location: "ichikawa"))
    UserProfileView(viewModel: viewModel)
  }
}
