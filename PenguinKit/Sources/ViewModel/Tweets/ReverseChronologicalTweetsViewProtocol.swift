//
//  ReverseChronologicalTweetsViewProtocol.swift
//

import CoreData
import Foundation
import RegexBuilder
import Sweet

protocol ReverseChronologicalTweetsViewProtocol: ObservableObject {
  var userID: String { get }
  var errorHandle: ErrorHandle? { get set }
  var backgroundContext: NSManagedObjectContext { get }
  var searchSettings: TimelineSearchSettings { get set }
  var reply: Reply? { get set }

  func fetchTweets(last lastTweetID: String?, paginationToken: String?) async
}

extension ReverseChronologicalTweetsViewProtocol {
  //  var showTweets: [Tweet] {
  //    let tweets = fetchShowTweetController.fetchedObjects ?? []
  //
  //    if searchSettings.query.isEmpty {
  //      return tweets
  //    } else {
  //      return tweets.filter { $0.text!.lowercased().contains(searchSettings.query.lowercased()) }
  //    }
  //  }

  func tweetCellOnAppear(tweet: Sweet.TweetModel) async {
    //    guard let lastTweet = showTweets.last else { return }
    //    guard tweet.id == lastTweet.id else { return }
    //    await fetchTweets(last: tweet.id, paginationToken: nil)
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
      let tweet = getTweet(quoted.id) /* TODO 引用先のツイートが非公開アカウントのツイートの可能性があるためif letアンラップ */
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

  @MainActor
  func getTweetCellViewModel(_ tweetID: String) -> TweetCellViewModel {
    let tweet = getTweet(tweetID)!

    let author = getUser(tweet.authorID!)!

    let retweet: TweetContentModel? = retweetContent(tweet: tweet)

    let quoted: QuotedTweetModel? = quotedContent(tweet: tweet, retweet: retweet?.tweet)

    let tweets = [
      tweet,
      retweet?.tweet,
      quoted?.tweetContent.tweet,
      quoted?.quoted?.tweet,
    ].compacted()

    let mediaKeys = tweets.compactMap(\.attachments).flatMap(\.mediaKeys)
    let medias = getMedias(Array(mediaKeys.uniqued()))

    let pollIDs = tweets.compactMap(\.attachments).compactMap(\.pollID)
    let polls = getPolls(pollIDs)

    let placeIDs = tweets.compactMap(\.geo).compactMap(\.placeID)
    let places = getPlaces(placeIDs)

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
