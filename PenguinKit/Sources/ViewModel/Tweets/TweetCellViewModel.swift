//
//  TweetViewModel.swift
//

import Combine
import Foundation
import MapKit
import Sweet

protocol TweetCellViewProtocol: Hashable {
  var userID: String { get }

  var author: Sweet.UserModel { get }
  var tweet: Sweet.TweetModel { get }

  var retweet: TweetContentModel? { get }
  var quoted: QuotedTweetModel? { get }

  var medias: [Sweet.MediaModel] { get }
  var polls: [Sweet.PollModel] { get }
  var places: [Sweet.PlaceModel] { get }
  var tweetText: Sweet.TweetModel { get }
  var showDate: Date { get }
}

struct TweetCellViewModel: TweetCellViewProtocol {
  let userID: String
  let author: Sweet.UserModel
  let tweet: Sweet.TweetModel
  let retweet: TweetContentModel?
  let quoted: QuotedTweetModel?
  let medias: [Sweet.MediaModel]
  let polls: [Sweet.PollModel]
  let places: [Sweet.PlaceModel]

  init(
    userID: String,
    tweet: Sweet.TweetModel,
    author: Sweet.UserModel,
    retweet: TweetContentModel?,
    quoted: QuotedTweetModel?,
    medias: [Sweet.MediaModel],
    polls: [Sweet.PollModel],
    places: [Sweet.PlaceModel]
  ) {
    self.userID = userID
    self.tweet = tweet
    self.author = author
    self.retweet = retweet
    self.quoted = quoted
    self.medias = medias
    self.polls = polls
    self.places = places
  }

  nonisolated func hash(into hasher: inout Hasher) {
    hasher.combine(userID)
    hasher.combine(author)
    hasher.combine(tweet)
    hasher.combine(retweet)
    hasher.combine(quoted)
    hasher.combine(medias)
    hasher.combine(polls)
    hasher.combine(places)
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

extension TweetCellViewModel {
  static let placeHolder = TweetCellViewModel(
    userID: "userID",
    tweet: .init(
      id: "id",
      text: "This is Placeholder Text.\n This  tweets is loading...",
      createdAt: .now.addingTimeInterval(-1000),
      attachments: .init(pollID: "pollID")
    ),
    author: .init(
      id: "id",
      name: "name",
      userName: "userName",
      verified: true,
      profileImageURL: URL(
        string: "https://pbs.twimg.com/profile_images/974322170309390336/tY8HZIhk_400x400.jpg")!
    ),
    retweet: nil,
    quoted: nil,
    medias: [],
    polls: [
      .init(
        id: "pollID",
        votingStatus: .isOpen,
        endDateTime: .now,
        durationMinutes: 10,
        options: [
          .init(position: 1, label: "label1", votes: 40),
          .init(position: 2, label: "label2", votes: 100),
        ]
      )
    ],
    places: []
  )
}
