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
  var reply: Reply? { get set }
  var timelines: [Timeline] { get set }
  func addResponse(response: Sweet.TweetsResponse) throws
  func addTimelines(_ ids: [String]) throws
  func containsTimelineDataBase(tweetID: String) throws -> Bool
  func setTimelines() async
  func fetchTweets(last lastTweetID: String?, paginationToken: String?) async
}

extension ReverseChronologicalTweetsViewProtocol {
  func addResponse(response: Sweet.TweetsResponse) throws {
    let tweets = response.tweets + response.relatedTweets

    if !tweets.isEmpty {
      let request = NSBatchInsertRequest(
        entity: Tweet.entity(),
        objects: tweets.map { $0.dictionaryValue() }
      )
      try backgroundContext.execute(request)
    }

    if !response.users.isEmpty {
      let request = NSBatchInsertRequest(
        entity: User.entity(),
        objects: response.users.map { $0.dictionaryValue() }
      )
      try backgroundContext.execute(request)
    }

    if !response.medias.isEmpty {
      let request = NSBatchInsertRequest(
        entity: Media.entity(),
        objects: response.medias.map { $0.dictionaryValue() }
      )
      try backgroundContext.execute(request)
    }

    if !response.polls.isEmpty {
      let request = NSBatchInsertRequest(
        entity: Poll.entity(),
        objects: response.polls.map { $0.dictionaryValue() }
      )
      try backgroundContext.execute(request)
    }

    if !response.places.isEmpty {
      let request = NSBatchInsertRequest(
        entity: Place.entity(),
        objects: response.places.map { $0.dictionaryValue() }
      )
      try backgroundContext.execute(request)
    }
  }

  func addTimelines(_ ids: [String]) throws {
    let request = NSBatchInsertRequest(
      entity: Timeline.entity(),
      objects: ids.map { ["tweetID": $0, "ownerID": userID] }
    )

    try backgroundContext.execute(request)
  }

  func containsTimelineDataBase(tweetID: String) throws -> Bool {
    let request = Timeline.fetchRequest()
    request.predicate = .init(format: "tweetID = %@ AND ownerID = %@", tweetID, userID)
    request.fetchLimit = 1
    let tweetCount = try self.backgroundContext.count(for: request)

    return tweetCount > 0
  }

  @MainActor
  func setTimelines() async {
    let request = Timeline.fetchRequest()
    request.predicate = .init(format: "ownerID = %@", userID)
    request.sortDescriptors = [.init(keyPath: \Timeline.tweetID, ascending: false)]
    do {
      timelines = try await backgroundContext.perform {
        try self.backgroundContext.fetch(request)
      }
    } catch {
      let errorHandle = ErrorHandle(error: error)
      errorHandle.log()
      self.errorHandle = errorHandle
    }
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

      try await backgroundContext.perform {
        for response in responses {
          try self.addResponse(response: response)
        }

        try self.addResponse(response: response)
      }

      let containsTweet: Bool = try await backgroundContext.perform {
        guard let lastTweetID = response.tweets.last?.id else { return true }

        return try self.containsTimelineDataBase(tweetID: lastTweetID)
      }

      try await backgroundContext.perform {
        try self.addTimelines(response.tweets.map(\.id))
      }

      if let paginationToken = response.meta?.nextToken, !containsTweet {
        await fetchTweets(last: nil, paginationToken: paginationToken)
      }

      await setTimelines()
    } catch {
      let errorHandle = ErrorHandle(error: error)
      errorHandle.log()
      self.errorHandle = errorHandle
    }
  }
}
