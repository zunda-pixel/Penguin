//
//  ReverseChronologicalTweetsViewProtocol.swift
//

import CoreData
import Foundation
import Sweet

@MainActor
protocol ReverseChronologicalTweetsViewProtocol: NSFetchedResultsControllerDelegate,
  ObservableObject
{
  var loadingTweets: Bool { get set }

  var userID: String { get }

  var errorHandle: ErrorHandle? { get set }

  var viewContext: NSManagedObjectContext { get }
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
  var timelines: [String] { fetchTimelineController.fetchedObjects?.map(\.tweetID!) ?? [] }
  var showTweets: [Tweet] { fetchShowTweetController.fetchedObjects ?? [] }
  var allTweets: [Tweet] { fetchTweetController.fetchedObjects ?? [] }
  var allUsers: [User] { fetchUserController.fetchedObjects ?? [] }
  var allMedias: [Media] { fetchMediaController.fetchedObjects ?? [] }
  var allPolls: [Poll] { fetchPollController.fetchedObjects ?? [] }
  var allPlaces: [Place] { fetchPlaceController.fetchedObjects ?? [] }

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

  func getTweetCellViewModel(_ tweetID: String) -> TweetCellViewModel {
    let tweet = getTweet(tweetID)!

    let author = getUser(tweet.authorID!)!

    let retweet: TweetAndUser? = {
      let retweet = tweet.referencedTweets.first(where: { $0.type == .retweeted })

      guard let retweet else { return nil }

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

      let tweet = getTweet(quotedTweetID)!
      let user = getUser(tweet.authorID!)!

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
