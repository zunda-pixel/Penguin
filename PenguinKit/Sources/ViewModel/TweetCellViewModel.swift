//
//  TweetViewModel.swift
//

import Combine
import Foundation
import MapKit
import Sweet

@MainActor protocol TweetCellViewProtocol: ObservableObject, Hashable {
  var userID: String { get }
  var errorHandle: ErrorHandle? { get set }

  var author: Sweet.UserModel { get }
  var tweet: Sweet.TweetModel { get }

  var retweet: TweetContentModel? { get }
  var quoted: QuotedTweetModel? { get }

  var medias: [Sweet.MediaModel] { get }
  var poll: Sweet.PollModel? { get }
  var place: Sweet.PlaceModel? { get }
  var tweetText: Sweet.TweetModel { get }
  var showDate: Date { get }
}

@MainActor class TweetCellViewModel: TweetCellViewProtocol, Sendable {
  let userID: String
  let author: Sweet.UserModel
  let tweet: Sweet.TweetModel
  let retweet: TweetContentModel?
  let quoted: QuotedTweetModel?
  let medias: [Sweet.MediaModel]
  let poll: Sweet.PollModel?
  let place: Sweet.PlaceModel?

  @Published var errorHandle: ErrorHandle?

  init(
    userID: String,
    tweet: Sweet.TweetModel,
    author: Sweet.UserModel,
    retweet: TweetContentModel? = nil,
    quoted: QuotedTweetModel? = nil,
    medias: [Sweet.MediaModel] = [],
    poll: Sweet.PollModel? = nil,
    place: Sweet.PlaceModel? = nil
  ) {
    self.userID = userID
    self.tweet = tweet
    self.author = author
    self.retweet = retweet
    self.quoted = quoted
    self.medias = medias
    self.poll = poll
    self.place = place
  }

  nonisolated func hash(into hasher: inout Hasher) {
    hasher.combine(userID)
    hasher.combine(author)
    hasher.combine(tweet)
    hasher.combine(retweet)
    hasher.combine(quoted)
    hasher.combine(medias)
    hasher.combine(poll)
    hasher.combine(place)
  }

  nonisolated static func == (lhs: TweetCellViewModel, rhs: TweetCellViewModel) -> Bool {
    lhs.userID == rhs.userID && lhs.tweet.id == rhs.tweet.id
  }

  var tweetText: Sweet.TweetModel {
    let isRetweeted = tweet.referencedTweets.contains { $0.type == .retweeted }

    let tweet = isRetweeted ? retweet!.tweet : tweet

    return tweet
  }

  var showDate: Date {
    let isRetweeted = tweet.referencedTweets.contains { $0.type == .retweeted }

    if isRetweeted {
      return retweet!.tweet.createdAt!
    } else {
      return tweet.createdAt!
    }
  }
}
