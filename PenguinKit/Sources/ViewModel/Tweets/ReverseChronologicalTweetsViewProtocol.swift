//
//  ReverseChronologicalTweetsViewProtocol.swift
//

import CoreData
import Foundation
import RegexBuilder
import Sweet

@MainActor
protocol ReverseChronologicalTweetsViewProtocol: NSFetchedResultsControllerDelegate,
  ObservableObject
{
  var loadingTweets: Bool { get set }
  var userID: String { get }
  var errorHandle: ErrorHandle? { get set }
  var viewContext: NSManagedObjectContext { get }
  var searchSettings: TimelineSearchSettings { get set }
  var reply: Reply? { get set }

  func fetchTweets(last lastTweetID: String?, paginationToken: String?) async
  func updateTimeLine()

  var fetchTimelineController: NSFetchedResultsController<Timeline> { get }
  var fetchShowTweetController: NSFetchedResultsController<Tweet> { get }
}

extension ReverseChronologicalTweetsViewProtocol {
  var timelines: Set<String> { Set(fetchTimelineController.fetchedObjects?.map(\.tweetID!) ?? []) }

  var showTweets: [Tweet] {
    let tweets = fetchShowTweetController.fetchedObjects ?? []

    if searchSettings.query.isEmpty {
      return tweets
    } else {
      return tweets.filter { $0.text!.lowercased().contains(searchSettings.query.lowercased()) }
    }
  }

  func tweetCellOnAppear(tweet: Sweet.TweetModel) async {
    guard let lastTweet = showTweets.last else { return }
    guard tweet.id == lastTweet.id else { return }
    await fetchTweets(last: tweet.id, paginationToken: nil)
  }

  func fetchNewTweet() async {
    guard !loadingTweets else { return }

    loadingTweets.toggle()

    defer {
      loadingTweets.toggle()
    }

    await fetchTweets(last: nil, paginationToken: nil)
  }

  func getTweet(_ tweetID: String) -> Sweet.TweetModel? {
    let request = NSFetchRequest<Tweet>()
    request.entity = Tweet.entity()
    request.predicate = .init(format: "id = %@", tweetID)
    request.fetchLimit = 1
    
    let tweets = try! viewContext.fetch(request)
    
    return tweets.first.map { .init(tweet: $0) }
  }

  func addPlace(_ place: Sweet.PlaceModel) throws {
    let request = NSFetchRequest<Place>()
    request.entity = Place.entity()
    request.predicate = .init(format: "id = %@", place.id)
    request.fetchLimit = 1
    
    let places = try! viewContext.fetch(request)
    
    if let firstPlace = places.first {
      firstPlace.setPlaceModel(place)
    } else {
      let newPlace = Place(context: viewContext)
      newPlace.setPlaceModel(place)
    }
  }

  func addTweet(_ tweet: Sweet.TweetModel) throws {
    let request = NSFetchRequest<Tweet>()
    request.entity = Tweet.entity()
    request.predicate = .init(format: "id = %@", tweet.id)
    request.fetchLimit = 1
        
    let tweets = try viewContext.fetch(request)
    
    if let firstTweet = tweets.first {
      firstTweet.setTweetModel(tweet)
    } else {
      let newTweet = Tweet(context: viewContext)
      newTweet.setTweetModel(tweet)
    }
  }

  func addPoll(_ poll: Sweet.PollModel) throws {
    let request = NSFetchRequest<Poll>()
    request.entity = Poll.entity()
    request.predicate = .init(format: "id = %@", poll.id)
    request.fetchLimit = 1
    
    let polls = try viewContext.fetch(request)
    
    if let firstPoll = polls.first {
      try firstPoll.setPollModel(poll)
    } else {
      let newPoll = Poll(context: viewContext)
      try newPoll.setPollModel(poll)
    }
  }

  func addUser(_ user: Sweet.UserModel) throws {
    let request = NSFetchRequest<User>()
    request.entity = User.entity()
    request.predicate = .init(format: "id = %@", user.id)
    request.fetchLimit = 1
    
    let users = try viewContext.fetch(request)
    
    if let firstUser = users.first {
      try firstUser.setUserModel(user)
    } else {
      let newUser = User(context: viewContext)
      try newUser.setUserModel(user)
    }
  }

  func addMedia(_ media: Sweet.MediaModel) throws {
    let request = NSFetchRequest<Media>()
    request.entity = Media.entity()
    request.predicate = .init(format: "key = %@", media.id)
    request.fetchLimit = 1
    
    let medias = try viewContext.fetch(request)
    
    if let firstMedia = medias.first {
      firstMedia.setMediaModel(media)
    } else {
      let newMedia = Media(context: viewContext)
      newMedia.setMediaModel(media)
    }
  }

  func addTimeline(_ tweetID: String) throws {
    if timelines.contains(where: { $0 == tweetID }) {
      return
    }

    let newTimeline = Timeline(context: viewContext)
    newTimeline.tweetID = tweetID
    newTimeline.ownerID = userID
  }

  func updateTimeLine() {
    fetchShowTweetController.fetchRequest.predicate = .init(format: "id IN %@", timelines)
    try! fetchShowTweetController.performFetch()
  }

  func getPlaces(_ placeIDs: [String]) -> [Sweet.PlaceModel] {
    let request = NSFetchRequest<Place>()
    request.entity = Place.entity()
    request.predicate = .init(format: "id IN %@", placeIDs)
    request.fetchLimit = placeIDs.count
    
    let places = try! viewContext.fetch(request)
    
    return places.map { .init(place: $0) }
  }

  func getPolls(_ pollIDs: [String]) -> [Sweet.PollModel] {
    let request = NSFetchRequest<Poll>()
    request.entity = Poll.entity()
    request.predicate = .init(format: "id IN %@", pollIDs)
    request.fetchLimit = pollIDs.count
    
    let polls = try! viewContext.fetch(request)
    
    return polls.map { .init(poll: $0) }
  }

  func getMedias(_ mediaIDs: [String]) -> [Sweet.MediaModel] {
    let request = NSFetchRequest<Media>()
    request.entity = Media.entity()
    request.predicate = .init(format: "key IN %@", mediaIDs)
    request.fetchLimit = mediaIDs.count
    
    let medias = try! viewContext.fetch(request)
    
    return medias.map { .init(media: $0) }
  }

  func getUser(_ userID: String) -> Sweet.UserModel? {
    let request = NSFetchRequest<User>()
    request.entity = User.entity()
    request.predicate = .init(format: "id = %@", userID)
    request.fetchLimit = 1
    
    let users = try! viewContext.fetch(request)
    
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
       let tweet = getTweet(quoted.id) /* TODO 引用先のツイートが非公開アカウントのツイートの可能性があるためif letアンラップ */{
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
