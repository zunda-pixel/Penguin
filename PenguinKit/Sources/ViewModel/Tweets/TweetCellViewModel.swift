//
//  TweetViewModel.swift
//

import Combine
import Foundation
import MapKit
import Sweet
import RegexBuilder

protocol TweetCellViewProtocol: Hashable {
  var userID: String { get }

  var author: Sweet.UserModel { get }
  var tweet: Sweet.TweetModel { get }

  var retweet: TweetContentModel? { get }
  var quoted: QuotedTweetModel? { get }

  var medias: [Sweet.MediaModel] { get }
  var polls: [Sweet.PollModel] { get }
  var places: [Sweet.PlaceModel] { get }
}

extension TweetCellViewProtocol {
  var ogpURL: Sweet.URLModel? {
    if quoted != nil { return nil }
    
    let mediaKeys = tweetText.attachments?.mediaKeys ?? []
    guard mediaKeys.isEmpty else { return nil }

    return tweet.entity?.urls.filter {
      // TODO statusがnilの場合がある
      let status =  $0.status ?? 401
      return !$0.images.isEmpty && (200..<300).contains(status)
    }.last
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
    
    guard let urls = tweetText.entity?.urls else { return excludeURLs }
    
    let regex = Regex {
      Anchor.startOfLine
      "http"
      ZeroOrMore("s")
      "://twitter.com/"
      OneOrMore(.whitespace.inverted)
      "/status/"
      tweetText.id
      Anchor.endOfLine
    }
    
    for url in urls {
      guard let expandedURL = url.expandedURL else { continue }
      if expandedURL.isMatchWhole(of: regex) {
        excludeURLs.append(url)
      }
    }
    
    guard let quoted else { return excludeURLs }
    
    let quotedURL = "https://twitter.com/\(quoted.tweetContent.author.userName)/status/\(quoted.tweetContent.tweet.id)"

    let matchedURLs = urls.filter { $0.expandedURL?.lowercased() == quotedURL.lowercased() }
    excludeURLs.append(contentsOf: matchedURLs)

    return excludeURLs
  }

  var tweetAuthor: Sweet.UserModel {
    let isRetweeted = tweet.referencedType == .retweet
    
    let tweet = isRetweeted ? retweet!.author : author

    return tweet
  }
  
  var tweetText: Sweet.TweetModel {
    let isRetweeted = tweet.referencedType == .retweet

    let tweet = isRetweeted ? retweet!.tweet : tweet

    return tweet
  }

  var showDate: Date {
    let isRetweeted = tweet.referencedType == .retweet

    if isRetweeted {
      return retweet!.tweet.createdAt!
    } else {
      return tweet.createdAt!
    }
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
}

extension TweetCellViewModel {
  static let placeHolder = TweetCellViewModel(
    userID: "userID",
    tweet: .placeHolder,
    author: .placeHolder,
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
