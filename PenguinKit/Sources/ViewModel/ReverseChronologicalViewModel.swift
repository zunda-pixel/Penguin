//
//  ReverseChronologicalViewModel.swift
//

import Algorithms
import CoreData
import Foundation
import Sweet

@MainActor
final class ReverseChronologicalViewModel: NSObject, ReverseChronologicalTweetsViewProtocol {
  let userID: String

  let viewContext: NSManagedObjectContext
  let fetchTimelineController: NSFetchedResultsController<Timeline>
  let fetchShowTweetController: NSFetchedResultsController<Tweet>
  let fetchTweetController: NSFetchedResultsController<Tweet>
  let fetchUserController: NSFetchedResultsController<User>
  let fetchMediaController: NSFetchedResultsController<Media>
  let fetchPollController: NSFetchedResultsController<Poll>
  let fetchPlaceController: NSFetchedResultsController<Place>

  @Published var searchSettings: TimelineSearchSettings
  @Published var loadingTweets: Bool
  @Published var errorHandle: ErrorHandle?
  @Published var reply: Reply?

  init(userID: String, viewContext: NSManagedObjectContext) {
    self.userID = userID
    self.viewContext = viewContext

    self.loadingTweets = false

    self.searchSettings = TimelineSearchSettings(query: "")

    self.fetchTimelineController = {
      let fetchRequest = NSFetchRequest<Timeline>()
      fetchRequest.entity = Timeline.entity()
      fetchRequest.sortDescriptors = []
      fetchRequest.predicate = .init(format: "ownerID = %@", userID)

      return NSFetchedResultsController<Timeline>(
        fetchRequest: fetchRequest,
        managedObjectContext: viewContext,
        sectionNameKeyPath: nil,
        cacheName: nil
      )
    }()

    self.fetchShowTweetController = {
      let fetchRequest = NSFetchRequest<Tweet>()
      fetchRequest.entity = Tweet.entity()
      fetchRequest.sortDescriptors = [.init(keyPath: \Tweet.createdAt, ascending: false)]

      return NSFetchedResultsController<Tweet>(
        fetchRequest: fetchRequest,
        managedObjectContext: viewContext,
        sectionNameKeyPath: nil,
        cacheName: nil
      )
    }()

    self.fetchTweetController = {
      let fetchRequest = NSFetchRequest<Tweet>()
      fetchRequest.entity = Tweet.entity()
      fetchRequest.sortDescriptors = []

      return NSFetchedResultsController<Tweet>(
        fetchRequest: fetchRequest,
        managedObjectContext: viewContext,
        sectionNameKeyPath: nil,
        cacheName: nil
      )
    }()

    self.fetchUserController = {
      let fetchRequest = NSFetchRequest<User>()
      fetchRequest.entity = User.entity()
      fetchRequest.sortDescriptors = []

      return NSFetchedResultsController<User>(
        fetchRequest: fetchRequest,
        managedObjectContext: viewContext,
        sectionNameKeyPath: nil,
        cacheName: nil
      )
    }()

    self.fetchPollController = {
      let fetchRequest = NSFetchRequest<Poll>()
      fetchRequest.entity = Poll.entity()
      fetchRequest.sortDescriptors = []

      return NSFetchedResultsController<Poll>(
        fetchRequest: fetchRequest,
        managedObjectContext: viewContext,
        sectionNameKeyPath: nil,
        cacheName: nil
      )
    }()

    self.fetchMediaController = {
      let fetchRequest = NSFetchRequest<Media>()
      fetchRequest.entity = Media.entity()
      fetchRequest.sortDescriptors = []

      return NSFetchedResultsController<Media>(
        fetchRequest: fetchRequest,
        managedObjectContext: viewContext,
        sectionNameKeyPath: nil,
        cacheName: nil
      )
    }()

    self.fetchPlaceController = {
      let fetchRequest = NSFetchRequest<Place>()
      fetchRequest.entity = Place.entity()
      fetchRequest.sortDescriptors = []

      return NSFetchedResultsController<Place>(
        fetchRequest: fetchRequest,
        managedObjectContext: viewContext,
        sectionNameKeyPath: nil,
        cacheName: nil
      )
    }()

    super.init()

    fetchTimelineController.delegate = self
    fetchShowTweetController.delegate = self
    fetchTweetController.delegate = self
    fetchUserController.delegate = self
    fetchPlaceController.delegate = self
    fetchPollController.delegate = self
    fetchMediaController.delegate = self

    try! fetchTimelineController.performFetch()
    try! fetchShowTweetController.performFetch()
    try! fetchTweetController.performFetch()
    try! fetchUserController.performFetch()
    try! fetchPlaceController.performFetch()
    try! fetchPollController.performFetch()
    try! fetchMediaController.performFetch()

    updateTimeLine()
  }

  nonisolated func controllerWillChangeContent(
    _ controller: NSFetchedResultsController<NSFetchRequestResult>
  ) {
    objectWillChange.send()
  }

  func addResponse(response: Sweet.TweetsResponse) throws {
    try response.tweets.forEach { tweet in
      try addTweet(tweet)
    }

    try response.relatedTweets.forEach { tweet in
      try addTweet(tweet)
    }

    try response.users.forEach { user in
      try addUser(user)
    }

    try response.medias.forEach { media in
      try addMedia(media)
    }
    try response.polls.forEach { poll in
      try addPoll(poll)
    }

    try response.places.forEach { place in
      try addPlace(place)
    }
  }

  func fetchTweets(last lastTweetID: String?, paginationToken: String?) async {
    do {
      let response = try await Sweet(userID: userID).reverseChronological(
        userID: userID,
        untilID: lastTweetID,
        paginationToken: paginationToken
      )

      let quotedQuotedTweetIDs = response.relatedTweets.lazy.flatMap(\.referencedTweets)
        .filter { $0.type == .quoted }
        .map(\.id)
      
      let ids = quotedQuotedTweetIDs + response.relatedTweets.map(\.id)
      
      let responses = try await Sweet(userID: userID).tweets(ids: Set(ids))
      
      for response in responses {
        try addResponse(response: response)
      }

      try addResponse(response: response)

      let containsTweet = response.tweets.last.map { timelines.contains($0.id) } ?? false

      try response.tweets.forEach { tweet in
        try addTimeline(tweet.id)
      }

      updateTimeLine()

      if let paginationToken = response.meta?.nextToken, !containsTweet {
        await fetchTweets(last: nil, paginationToken: paginationToken)
      }
    } catch {
      let errorHandle = ErrorHandle(error: error)
      errorHandle.log()
      self.errorHandle = errorHandle
    }
  }
}
