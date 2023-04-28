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

extension TweetCellViewProtocol {
  var ogpURL: Sweet.URLModel? {
    let mediaKeys = tweetText.attachments?.mediaKeys ?? []
    guard mediaKeys.isEmpty else { return nil }
    
    return tweet.entity?.urls.filter {
      // TODO statusがnilの場合がある
      // 対処しなくてもいい
      !$0.images.isEmpty && (200..<300).contains($0.status ?? 401)
    }.first
  }
  
  var poll: Sweet.PollModel? {
    guard let pollID = tweetText.attachments?.pollID else { return nil }
    return polls.first { $0.id == pollID }
  }
  
  var place: Sweet.PlaceModel? {
    guard let placeID = tweetText.geo?.placeID else { return nil }
    return places.first { $0.id == placeID }
  }
  
  var showMedias: [Sweet.MediaModel] {
    guard let mediaKeys = tweetText.attachments?.mediaKeys else { return [] }
    return mediaKeys.compactMap { id in
      self.medias.first { $0.id == id }
    }
  }
  
  var excludeURLs: some Sequence<Sweet.URLModel> {
    var excludeURLs = [ogpURL].compactMap { $0 }
    
    let quotedURL = quoted.map { "https://twitter.com/\($0.tweetContent.author.userName.lowercased())/status/\($0.tweetContent.tweet.id)"
    }
    
    guard let quotedURL else { return excludeURLs }
        
    if let entity = tweet.entity {
      let urls = entity.urls.filter {
        return $0.expandedURL == quotedURL
      }
      excludeURLs.append(contentsOf: urls)
    }
    
    return excludeURLs
  }
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

  func isValidateTweet(settings: TimelineSearchSettings) -> Bool {
    let lowercasedQuery = settings.query.lowercased()

    if lowercasedQuery.isEmpty { return true }

    let words = [
      tweet.text,

      retweet?.tweet.text,

      quoted?.tweetContent.tweet.text,
      quoted?.quoted?.tweet.text,

      author.name,
      author.userName,

      retweet?.author.name,
      retweet?.author.userName,

      quoted?.tweetContent.author.name,
      quoted?.tweetContent.author.userName,

      quoted?.quoted?.author.name,
      quoted?.quoted?.author.userName,
    ]
    .compacted()
    .map { $0.lowercased() }

    return words.contains { $0.contains(lowercasedQuery) }
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
