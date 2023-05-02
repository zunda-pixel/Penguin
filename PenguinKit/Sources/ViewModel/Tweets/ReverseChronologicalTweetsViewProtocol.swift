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

  func addTimelines(_ ids: [String]) throws {
    let request = NSBatchInsertRequest(
      entity: Timeline.entity(),
      objects: ids.map { ["tweetID": $0, "ownerID": userID ]}
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
  
  func getTimelines() async throws -> [Timeline] {
    let request = Timeline.fetchRequest()
    request.predicate = .init(format: "ownerID = %@", userID)
    request.sortDescriptors = [.init(keyPath: \Timeline.tweetID, ascending: false)]
    return try await backgroundContext.perform {
      try self.backgroundContext.fetch(request)
    }
  }
}
