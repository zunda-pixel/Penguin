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

        Text(tweet.tweetText)
          .lineLimit(nil)
          .fixedSize(horizontal: false, vertical: true)
      }
    }
  }
}
