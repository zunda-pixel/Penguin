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

      Label("\(metrics.retweetCount)", systemImage: "arrow.2.squarepath")
        .onTapGesture {
          let retweetUsersViewModel: RetweetUsersViewModel = .init(userID: userID, tweetID: tweetID)
          router.path.append(retweetUsersViewModel)
        }

      Label("\(metrics.quoteCount)", systemImage: "quote.bubble")
        .onTapGesture {
          let quoteTweetViewModel: QuoteTweetsViewModel = .init(userID: userID, source: tweetID)
          router.path.append(quoteTweetViewModel)
        }

      Label("\(metrics.likeCount)", systemImage: "heart")
        .onTapGesture {
          let likeUsersViewModel: LikeUsersViewModel = .init(userID: userID, tweetID: tweetID)
          router.path.append(likeUsersViewModel)
        }
    }
    .frame(alignment: .leadingFirstTextBaseline)
  }
}
