//
//  ProfileImageView.swift
//

import Kingfisher
import SwiftUI

struct ProfileImageView: View {
  let url: URL
  let lineWidth: CGFloat = 2

  var body: some View {
    KFImage(url)
      .resizable()
      .background(.secondary)
      .clipShape(Circle())
      .overlay {
        Circle().stroke(.secondary, lineWidth: lineWidth)
      }
      .padding(lineWidth)
  }
}

struct ProfileImageView_Previews: PreviewProvider {
  static var previews: some View {
    let url: URL = .init(
      string: "https://pbs.twimg.com/profile_images/974322170309390336/tY8HZIhk.jpg"
    )!
    ProfileImageView(url: url)
      .frame(width: 200, height: 200)
  }
}
