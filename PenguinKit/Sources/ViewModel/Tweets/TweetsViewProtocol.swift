//
//  TweetsViewModel.swift
//

import Foundation
import Sweet

@MainActor protocol TweetsViewProtocol: ObservableObject, Hashable {
  var userID: String { get }

  var errorHandle: ErrorHandle? { get set }

  var loadingTweet: Bool { get set }

  var allTweets: [Sweet.TweetModel] { get set }
  var allUsers: [Sweet.UserModel] { get set }
  var allMedias: [Sweet.MediaModel] { get set }
  var allPolls: [Sweet.PollModel] { get set }
  var allPlaces: [Sweet.PlaceModel] { get set }

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
      allTweets.appendOrUpdate($0)
    }

    response.relatedTweets.forEach {
      allTweets.appendOrUpdate($0)
    }

    response.users.forEach {
      allUsers.appendOrUpdate($0)
    }

    response.medias.forEach {
      allMedias.appendOrUpdate($0)
    }

    response.polls.forEach {
      allPolls.appendOrUpdate($0)
    }

    response.places.forEach {
      allPlaces.appendOrUpdate($0)
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
    let medias = allMedias.filter({ mediaIDs.contains($0.key) })

    return medias
  }

  func getUser(_ userID: String) -> Sweet.UserModel? {
    guard let firstUser = allUsers.first(where: { $0.id == userID }) else { return nil }

    return firstUser
  }

  func getTweetCellViewModel(_ tweetID: String) -> TweetCellViewModel {
    let tweet = getTweet(tweetID)!

    let author = getUser(tweet.authorID!)!

    let retweet: TweetAndUser? = {
      guard let retweet = tweet.referencedTweets.first(where: { $0.type == .retweeted }) else {
        return nil
      }

      let tweet = getTweet(retweet.id)!
      let user = getUser(tweet.authorID!)!

      return (tweet, user)
    }()

    let quoted: TweetAndUser? = {
      let quotedTweetID: String? = {
        if let quoted = tweet.referencedTweets.first(where: { $0.type == .quoted }) {
          return quoted.id
        }

        if let quoted = retweet?.tweet.referencedTweets.first(where: { $0.type == .quoted }) {
          return quoted.id
        }

        return nil
      }()

      guard let quotedTweetID else { return nil }

      // TODO 取得できていないツイートがある場合に、適当にデータを表示している

      guard let tweet = getTweet(quotedTweetID) else {
        return (.unknown, .unknown)
      }

      guard let user = getUser(tweet.authorID!) else {
        return (tweet, .unknown)
      }

      return (tweet, user)
    }()

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

extension Sweet.UserModel {
  fileprivate static var unknown: Sweet.UserModel {
    return .init(
      id: "🎃🎃🎃🎃🎃🎃", name: "🎃🎃🎃🎃🎃🎃", userName: "🎃🎃🎃🎃🎃🎃",
      profileImageURL: URL(
        string: "https://pbs.twimg.com/profile_images/1488548719062654976/u6qfBBkF_400x400.jpg")!)
  }
}

extension Sweet.TweetModel {
  fileprivate static var unknown: Sweet.TweetModel {
    return .init(id: "🎃🎃🎃🎃🎃🎃", text: "🎃🎃🎃🎃🎃🎃")
  }
}
