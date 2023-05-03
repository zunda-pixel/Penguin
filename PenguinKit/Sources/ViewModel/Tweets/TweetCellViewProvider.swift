//
//  TweetCellViewProvider.swift
//

import CoreData
import Foundation
import Sweet

struct TweetCellViewProvider {
  let backgroundContext: NSManagedObjectContext

  init() {
    backgroundContext = PersistenceController.shared.container.newBackgroundContext()
    backgroundContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
  }

  func getTweet(_ tweetID: String) -> Sweet.TweetModel? {
    let request = Tweet.fetchRequest()
    request.predicate = .init(format: "id = %@", tweetID)
    request.fetchLimit = 1

    let tweets = try! backgroundContext.fetch(request)

    return tweets.first.map { .init(tweet: $0) }
  }

  func getPlaces(_ placeIDs: [String]) -> [Sweet.PlaceModel] {
    let request = Place.fetchRequest()
    request.predicate = .init(format: "id IN %@", placeIDs)
    request.fetchLimit = placeIDs.count

    let places = try! backgroundContext.fetch(request)

    return places.map { .init(place: $0) }
  }

  func getPolls(_ pollIDs: [String]) -> [Sweet.PollModel] {
    let request = Poll.fetchRequest()
    request.predicate = .init(format: "id IN %@", pollIDs)
    request.fetchLimit = pollIDs.count

    let polls = try! backgroundContext.fetch(request)

    return polls.map { .init(poll: $0) }
  }

  func getMedias(_ mediaIDs: [String]) -> [Sweet.MediaModel] {
    let request = Media.fetchRequest()
    request.predicate = .init(format: "key IN %@", mediaIDs)
    request.fetchLimit = mediaIDs.count

    let medias = try! backgroundContext.fetch(request)

    return medias.map { .init(media: $0) }
  }

  func getUsers(screenIDs: [String]) -> [Sweet.UserModel] {
    let request = User.fetchRequest()
    request.predicate = .init(format: "userName IN %@", screenIDs)
    request.fetchLimit = screenIDs.count

    let users = try! backgroundContext.fetch(request)

    return users.map { .init(user: $0) }
  }
  
  func getUser(_ userID: String) -> Sweet.UserModel? {
    let request = User.fetchRequest()
    request.predicate = .init(format: "id = %@", userID)
    request.fetchLimit = 1

    let users = try! backgroundContext.fetch(request)

    return users.first.map { .init(user: $0) }
  }

  func retweetContent(tweet: Sweet.TweetModel) -> TweetContentModel? {
    let retweet = tweet.referencedTweets.first(where: { $0.type == .retweeted })

    guard let retweet else { return nil }

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

    if let quoted = tweet.referencedTweets.first(where: { $0.type == .quoted }),
      // TODO 引用先のツイートが非公開アカウントのツイートの可能性があるためif letアンラップ
      let tweet = getTweet(quoted.id)
    {
      let user = getUser(tweet.authorID!)!
      quotedQuotedTweet = TweetContentModel(tweet: tweet, author: user)
    } else {
      quotedQuotedTweet = nil
    }

    return QuotedTweetModel(
      tweetContent: .init(tweet: tweet, author: user),
      quoted: quotedQuotedTweet
    )
  }

  func getTweetCellViewModel(userID: String, tweetID: String) async -> TweetCellViewModel {
    return await backgroundContext.perform {
      let tweet = self.getTweet(tweetID)!

      let author = self.getUser(tweet.authorID!)!

      let retweet: TweetContentModel? = self.retweetContent(tweet: tweet)

      let quoted: QuotedTweetModel? = self.quotedContent(tweet: tweet, retweet: retweet?.tweet)

      let tweets = [
        tweet,
        retweet?.tweet,
        quoted?.tweetContent.tweet,
        quoted?.quoted?.tweet,
      ].compacted()

      let mediaKeys = tweets.compactMap(\.attachments).flatMap(\.mediaKeys)
      let medias = self.getMedias(Array(mediaKeys.uniqued()))

      let pollIDs = tweets.compactMap(\.attachments).compactMap(\.pollID)
      let polls = self.getPolls(pollIDs)

      let placeIDs = tweets.compactMap(\.geo).compactMap(\.placeID)
      let places = self.getPlaces(placeIDs)

      let viewModel: TweetCellViewModel = .init(
        userID: userID,
        tweet: tweet,
        author: author,
        retweet: retweet,
        quoted: quoted,
        medias: medias,
        polls: polls,
        places: places
      )

      return viewModel
    }
  }
}
