//
//  QuotedTweetCellView.swift
//

import Sweet
import SwiftUI

struct QuotedTweetCellView: View {
  let userID: String
  let tweet: Sweet.TweetModel
  let user: Sweet.UserModel

  var body: some View {
    HStack(alignment: .top) {
      ProfileImageView(url: user.profileImageURL!)
        .frame(width: 30, height: 30)

      VStack(alignment: .leading) {
        (Text(user.name) + Text(" @\(user.userName)").foregroundColor(.secondary))
          .lineLimit(1)

        LinkableText(tweet: tweet, userID: userID, excludeURLs: [])
          .lineLimit(nil)
          .fixedSize(horizontal: false, vertical: true)
      }
    }
  }
}

struct QuotedTweetCellView_Previews: PreviewProvider {
  static var previews: some View {
    QuotedTweetCellView(
      userID: "",
      tweet: .init(id: "id", text: "text"),
      user: .init(
        id: "id", name: "name", userName: "userName",
        profileImageURL: URL(
          string: "https://pbs.twimg.com/profile_images/974322170309390336/tY8HZIhk_400x400.jpg")))
  }
}
