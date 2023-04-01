//
//  ReverseChronologicalViewModel.swift
//

import Algorithms
import CoreData
import Foundation
import Sweet

final class ReverseChronologicalViewModel: NSObject, ReverseChronologicalTweetsViewProtocol {
  let userID: String

  let backgroundContext: NSManagedObjectContext
  let fetchTimelineController: NSFetchedResultsController<Timeline>
  let fetchShowTweetController: NSFetchedResultsController<Tweet>

  @Published var searchSettings: TimelineSearchSettings
  @Published var loadingTweets: Bool
  @Published var errorHandle: ErrorHandle?
  @Published var reply: Reply?

  init(userID: String) {
    self.userID = userID
    let backgroundContext = PersistenceController.shared.container.newBackgroundContext()
    backgroundContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
    
    self.backgroundContext = backgroundContext

    self.loadingTweets = false

    self.searchSettings = TimelineSearchSettings(query: "")

    self.fetchTimelineController = {
      let fetchRequest = NSFetchRequest<Timeline>()
      fetchRequest.entity = Timeline.entity()
      fetchRequest.sortDescriptors = []
      fetchRequest.predicate = .init(format: "ownerID = %@", userID)

      return NSFetchedResultsController<Timeline>(
        fetchRequest: fetchRequest,
        managedObjectContext: backgroundContext,
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
        managedObjectContext: backgroundContext,
        sectionNameKeyPath: nil,
        cacheName: nil
      )
    }()

    super.init()

    fetchTimelineController.delegate = self
    fetchShowTweetController.delegate = self

    try! fetchTimelineController.performFetch()
    try! fetchShowTweetController.performFetch()

    updateTimeLine()
  }

  nonisolated func controllerWillChangeContent(
    _ controller: NSFetchedResultsController<NSFetchRequestResult>
  ) {
    objectWillChange.send()
  }

  func addResponse(response: Sweet.TweetsResponse) throws {
    let tweets = response.tweets + response.relatedTweets
    let tweetsRequest = NSBatchInsertRequest(entity: Tweet.entity(), objects: tweets.map { $0.dictionaryValue() })
    try backgroundContext.execute(tweetsRequest)
    
    let usersRequest = NSBatchInsertRequest(entity: User.entity(), objects: response.users.map { $0.dictionaryValue() })
    try backgroundContext.execute(usersRequest)

    let mediasRequest = NSBatchInsertRequest(entity: Media.entity(), objects: response.medias.map { $0.dictionaryValue() })
    try backgroundContext.execute(usersRequest)
    
    let pollsRequest = NSBatchInsertRequest(entity: Poll.entity(), objects: response.polls.map { $0.dictionaryValue() })
    try backgroundContext.execute(pollsRequest)

    let placesRequest = NSBatchInsertRequest(entity: Place.entity(), objects: response.places.map { $0.dictionaryValue() })
    try backgroundContext.execute(placesRequest)
  }

  func fetchTweets(last lastTweetID: String?, paginationToken: String?) async {
    do {
      let response = try await Sweet(userID: userID).reverseChronological(
        userID: userID,
        untilID: lastTweetID,
        paginationToken: paginationToken
      )

      let quotedQuotedTweetIDs = response.relatedTweets.flatMap(\.referencedTweets).map(\.id)

      let ids = quotedQuotedTweetIDs + response.relatedTweets.map(\.id)

      let responses = try await Sweet(userID: userID).tweets(ids: Set(ids))

      var containsTweet: Bool = false
      
      try await backgroundContext.perform {
        for response in responses {
          try self.addResponse(response: response)
        }

        try self.addResponse(response: response)
        
        containsTweet = response.tweets.last.map { self.timelines.contains($0.id) } ?? false

        try response.tweets.forEach { tweet in
          try self.addTimeline(tweet.id)
        }
        
        self.updateTimeLine()
      }

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
