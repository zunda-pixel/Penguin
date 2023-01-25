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
  var fetchTweetController: NSFetchedResultsController<Tweet> { get }
  var fetchUserController: NSFetchedResultsController<User> { get }
  var fetchMediaController: NSFetchedResultsController<Media> { get }
  var fetchPollController: NSFetchedResultsController<Poll> { get }
  var fetchPlaceController: NSFetchedResultsController<Place> { get }
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

  var allTweets: Set<Tweet> { Set(fetchTweetController.fetchedObjects ?? []) }
  var allUsers: Set<User> { Set(fetchUserController.fetchedObjects ?? []) }
  var allMedias: Set<Media> { Set(fetchMediaController.fetchedObjects ?? []) }
  var allPolls: Set<Poll> { Set(fetchPollController.fetchedObjects ?? []) }
  var allPlaces: Set<Place> { Set(fetchPlaceController.fetchedObjects ?? []) }

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
    guard let tweet = allTweets.first(where: { $0.id == tweetID }) else { return nil }

    return .init(tweet: tweet)
  }

  func addPlace(_ place: Sweet.PlaceModel) throws {
    if let firstPlace = allPlaces.first(where: { $0.id == place.id }) {
      firstPlace.setPlaceModel(place)
    } else {
      let newPlace = Place(context: viewContext)
      newPlace.setPlaceModel(place)
    }

    try viewContext.save()
  }

  func addTweet(_ tweet: Sweet.TweetModel) throws {
    if let firstTweet = allTweets.first(where: { $0.id == tweet.id }) {
      firstTweet.setTweetModel(tweet)
    } else {
      let newTweet = Tweet(context: viewContext)
      newTweet.setTweetModel(tweet)
    }

    try viewContext.save()
  }

  func addPoll(_ poll: Sweet.PollModel) throws {
    if let firstPoll = allPolls.first(where: { $0.id == poll.id }) {
      try firstPoll.setPollModel(poll)
    } else {
      let newPoll = Poll(context: viewContext)
      try newPoll.setPollModel(poll)
    }
    try viewContext.save()
  }

  func addUser(_ user: Sweet.UserModel) throws {
    if let firstUser = allUsers.first(where: { $0.id == user.id }) {
      try firstUser.setUserModel(user)
    } else {
      let newUser = User(context: viewContext)
      try newUser.setUserModel(user)
    }
    try viewContext.save()
  }

  func addMedia(_ media: Sweet.MediaModel) throws {
    if let firstMedia = allMedias.first(where: { $0.key == media.key }) {
      firstMedia.setMediaModel(media)
    } else {
      let newMedia = Media(context: viewContext)
      newMedia.setMediaModel(media)
    }
    try viewContext.save()
  }

  func addTimeline(_ tweetID: String) throws {
    if timelines.contains(where: { $0 == tweetID }) {
      return
    }

    let newTimeline = Timeline(context: viewContext)
    newTimeline.tweetID = tweetID
    newTimeline.ownerID = userID
    try viewContext.save()
  }

  func updateTimeLine() {
    fetchShowTweetController.fetchRequest.predicate = .init(format: "id IN %@", timelines)
    try! fetchShowTweetController.performFetch()
  }

  func getPlace(_ placeID: String?) -> Sweet.PlaceModel? {
    guard let placeID else { return nil }

    guard let firstPlace = allPlaces.first(where: { $0.id == placeID }) else {
      return nil
    }

    return .init(place: firstPlace)
  }

  func getPoll(_ pollID: String?) -> Sweet.PollModel? {
    guard let pollID else { return nil }

    guard let firstPoll = allPolls.first(where: { $0.id == pollID }) else { return nil }

    return .init(poll: firstPoll)
  }

  func getMedias(_ mediaIDs: [String]) -> [Sweet.MediaModel] {
    let medias = allMedias.filter { mediaIDs.contains($0.key!) }

    return medias.map { .init(media: $0) }
  }

  func getUser(_ userID: String) -> Sweet.UserModel? {
    guard let firstUser = allUsers.first(where: { $0.id == userID }) else { return nil }

    return .init(user: firstUser)
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
