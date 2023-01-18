//
//  TweetContentModel.swift
//

import Sweet

struct TweetContentModel: Hashable {
  let tweet: Sweet.TweetModel
  let author: Sweet.UserModel
}

struct QuotedTweetModel: Hashable {
  let tweetContent: TweetContentModel
  let quoted: TweetContentModel?
}
