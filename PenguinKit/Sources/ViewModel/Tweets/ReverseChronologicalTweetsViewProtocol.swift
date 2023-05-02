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
}
