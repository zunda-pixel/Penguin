//
//  ReverseChronologicalViewModel.swift
//

import Algorithms
import CoreData
import Foundation
import Sweet

final class ReverseChronologicalViewModel: ReverseChronologicalTweetsViewProtocol {
  let userID: String

  let backgroundContext: NSManagedObjectContext

  @Published var searchSettings: TimelineSearchSettings
  @Published var errorHandle: ErrorHandle?
  @Published var reply: Reply?

  init(userID: String) {
    self.userID = userID
    self.backgroundContext = PersistenceController.shared.container.newBackgroundContext()
    self.backgroundContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump

    self.searchSettings = TimelineSearchSettings(query: "")
  }

  func addResponse(response: Sweet.TweetsResponse) throws {
    let tweets = response.tweets + response.relatedTweets

    if !tweets.isEmpty {
      let tweetsRequest = NSBatchInsertRequest(
        entity: Tweet.entity(), objects: tweets.map { $0.dictionaryValue() })
      try backgroundContext.execute(tweetsRequest)
    }

    if !response.users.isEmpty {
      let usersRequest = NSBatchInsertRequest(
        entity: User.entity(), objects: response.users.map { $0.dictionaryValue() })
      try backgroundContext.execute(usersRequest)
    }

    if !response.medias.isEmpty {
      let mediasRequest = NSBatchInsertRequest(
        entity: Media.entity(), objects: response.medias.map { $0.dictionaryValue() })
      try backgroundContext.execute(mediasRequest)
    }

    if !response.polls.isEmpty {
      let pollsRequest = NSBatchInsertRequest(
        entity: Poll.entity(), objects: response.polls.map { $0.dictionaryValue() })
      try backgroundContext.execute(pollsRequest)
    }

    if !response.places.isEmpty {
      let placesRequest = NSBatchInsertRequest(
        entity: Place.entity(), objects: response.places.map { $0.dictionaryValue() })
      try backgroundContext.execute(placesRequest)
    }
  }

  func addTimelines(_ tweets: [Sweet.TweetModel]) throws {
    let context = PersistenceController.shared.container.viewContext
    context.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump

    for tweet in tweets {
      let timeline = Timeline(context: context)
      timeline.tweetID = tweet.id
      timeline.createdAt = tweet.createdAt
      timeline.ownerID = userID
    }

    try context.save()
  }

  @MainActor
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

        containsTweet = true  //response.tweets.last.map { self.timelines.contains($0.id) } ?? false

        try self.addTimelines(response.tweets)
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
