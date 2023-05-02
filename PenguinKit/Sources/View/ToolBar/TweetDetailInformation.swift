//
//  TweetDetailInformation.swift
//

import Sweet
import SwiftUI

struct TweetDetailInformation: View {
  let userID: String
  let tweetID: String

  let metrics: Sweet.TweetPublicMetrics

  @EnvironmentObject var router: NavigationPathRouter

  var body: some View {
    HStack {
      Label("\(metrics.replyCount)", systemImage: "arrow.turn.up.left")

      Button {
        let retweetUsersViewModel = RetweetUsersViewModel(
          userID: userID,
          tweetID: tweetID
        )
        router.path.append(retweetUsersViewModel)

      } label: {
        Label("\(metrics.retweetCount)", systemImage: "arrow.2.squarepath")
      }

      Button {
        let quoteTweetViewModel = QuoteTweetsViewModel(
          userID: userID,
          source: tweetID
        )
        router.path.append(quoteTweetViewModel)
      } label: {
        Label("\(metrics.quoteCount)", systemImage: "quote.bubble")
      }

      Button {
        let likeUsersViewModel = LikeUsersViewModel(
          userID: userID,
          tweetID: tweetID
        )
        router.path.append(likeUsersViewModel)
      } label: {
        Label("\(metrics.likeCount)", systemImage: "heart")
      }
    }
    .frame(alignment: .leadingFirstTextBaseline)
  }
}

struct TweetDetailInformation_Preview: PreviewProvider {
  static var previews: some View {
    TweetDetailInformation(
      userID: "userID", tweetID: "tweetID",
      metrics: .init(retweetCount: 3, replyCount: 324423, likeCount: 34, quoteCount: 32))
  }
}
