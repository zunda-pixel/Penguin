//
//  UserProfileView.swift
//

import Sweet
import SwiftUI

struct UserProfileView: View {
  let user: Sweet.UserModel

  var body: some View {
    VStack {
      Text(user.name)
        .font(.title)

      Text("@\(user.userName)")
        .foregroundColor(.secondary)

      Text(user.description!)

      if let url = user.url {
        HStack {
          Image(systemName: "link")

          let urlModel = user.entity?.urls.first { $0.url == url }

          Link(urlModel!.displayURL ?? "\(urlModel!.url)", destination: url)
        }
      }

      HStack {
        Image(systemName: "bird")

        Text(user.createdAt!, style: .date)
      }

      if let location = user.location {
        HStack {
          Image(systemName: "location")
          Text(location)
        }
      }
    }
  }
}

struct UserProfileView_Previews: PreviewProvider {
  static var previews: some View {
    UserProfileView(
      user: .init(id: "3123131", name: "zunda", userName: "zunda_pixel", createdAt: Date()))
  }
}
