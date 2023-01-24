//
//  TweetsViewModel.swift
//

import Foundation
import Sweet

@MainActor protocol TweetsViewProtocol: ObservableObject, Hashable {
  var userID: String { get }

  var errorHandle: ErrorHandle? { get set }

  var loadingTweet: Bool { get set }
  var  reply: Reply? { get set }

  var allTweets: Set<Sweet.TweetModel> { get set }
  var allUsers: Set<Sweet.UserModel> { get set }
  var allMedias: Set<Sweet.MediaModel> { get set }
  var allPolls: Set<Sweet.PollModel> { get set }
  var allPlaces: Set<Sweet.PlaceModel> { get set }

  func getTweet(_ tweetID: String) -> Sweet.TweetModel?
  func getPoll(_ pollID: String?) -> Sweet.PollModel?
  func getUser(_ userID: String) -> Sweet.UserModel?
  func getMedias(_ mediaIDs: [String]) -> [Sweet.MediaModel]
  func getPlace(_ placeID: String?) -> Sweet.PlaceModel?

  func getTweetCellViewModel(_ tweetID: String) -> TweetCellViewModel

  func fetchTweets(first firstTweetID: String?, last lastTweetID: String?) async
  func addResponse(response: Sweet.TweetsResponse)
}

extension TweetsViewProtocol {
  func addResponse(response: Sweet.TweetsResponse) {
    response.tweets.forEach {
      allTweets.insertOrUpdate($0, by: \.id)
    }
    
    response.relatedTweets.forEach {
      allTweets.insertOrUpdate($0, by: \.id)
    }

    response.users.forEach {
      allUsers.insertOrUpdate($0, by: \.id)
    }

    response.medias.forEach {
      allMedias.insertOrUpdate($0, by: \.id)
    }

    response.polls.forEach {
      allPolls.insertOrUpdate($0, by: \.id)
    }

    response.places.forEach {
      allPlaces.insertOrUpdate($0, by: \.id)
    }
  }

  func getTweet(_ tweetID: String) -> Sweet.TweetModel? {
    guard let tweet = allTweets.first(where: { $0.id == tweetID }) else { return nil }

    return tweet
  }

  func getPlace(_ placeID: String?) -> Sweet.PlaceModel? {
    guard let placeID else { return nil }

    guard let firstPlace = allPlaces.first(where: { $0.id == placeID }) else {
      return nil
    }

    return firstPlace
  }

  func getPoll(_ pollID: String?) -> Sweet.PollModel? {
    guard let pollID else { return nil }

    guard let firstPoll = allPolls.first(where: { $0.id == pollID }) else { return nil }

    return firstPoll
  }

  func getMedias(_ mediaIDs: [String]) -> [Sweet.MediaModel] {
    let medias = allMedias.filter { mediaIDs.contains($0.key) }

    return medias.uniqued(by: \.id)
  }

  func getUser(_ userID: String) -> Sweet.UserModel? {
    guard let firstUser = allUsers.first(where: { $0.id == userID }) else { return nil }

    return firstUser
  }

  func retweetContent(tweet: Sweet.TweetModel) -> TweetContentModel? {
    guard let retweet = tweet.referencedTweets.first(where: { $0.type == .retweeted }) else {
      return nil
    }

    let tweet = getTweet(retweet.id)!
    let user = getUser(tweet.authorID!)!

    return TweetContentModel(tweet: tweet, author: user)
  }

  func quotedContent(tweet: Sweet.TweetModel, retweet: Sweet.TweetModel?) -> QuotedTweetModel? {
    let quotedTweetID: String?

    if let quoted = tweet.referencedTweets.first(where: { $0.type == .quoted }) {
      quotedTweetID = quoted.id
    } else if let quoted = retweet?.referencedTweets.first(where: { $0.type == .quoted }) {
      quotedTweetID = quoted.id
    } else {
      quotedTweetID = nil
    }

    guard let quotedTweetID else { return nil }

    let tweet = getTweet(quotedTweetID)!

    let user = getUser(tweet.authorID!)!

    let quotedQuotedTweet: TweetContentModel?

    if let quoted = tweet.referencedTweets.first(where: { $0.type == .quoted }) {
      let tweet = getTweet(quoted.id)!
      let user = getUser(tweet.authorID!)!
      quotedQuotedTweet = TweetContentModel(tweet: tweet, author: user)
    } else {
      quotedQuotedTweet = nil
    }

    return QuotedTweetModel(
      tweetContent: .init(tweet: tweet, author: user), quoted: quotedQuotedTweet)
  }

  func getTweetCellViewModel(_ tweetID: String) -> TweetCellViewModel {
    let tweet = getTweet(tweetID)!

    let author = getUser(tweet.authorID!)!

    let retweet: TweetContentModel? = retweetContent(tweet: tweet)

    let quoted: QuotedTweetModel? = quotedContent(tweet: tweet, retweet: retweet?.tweet)

    let medias = getMedias(tweet.attachments?.mediaKeys ?? [])

    let poll = getPoll(tweet.attachments?.pollID)

    let place = getPlace(tweet.geo?.placeID)

    let viewModel: TweetCellViewModel = .init(
      userID: userID,
      tweet: tweet,
      author: author,
      retweet: retweet,
      quoted: quoted,
      medias: medias,
      poll: poll,
      place: place
    )

    return viewModel
  }
}
