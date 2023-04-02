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

      var containsTweet: Bool = true

      try await backgroundContext.perform {
        for response in responses {
          try self.addResponse(response: response)
        }

        try self.addResponse(response: response)

        if let lastTweetID = response.tweets.last?.id {
          containsTweet = try self.containsTimelineDataBase(tweetID: lastTweetID)
        }

        try self.addTimelines(response.tweets.map(\.id))
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
