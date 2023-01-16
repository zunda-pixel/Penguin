//
//  SearchTweetsViewModel.swift
//

import Foundation
import Sweet

@MainActor final class SearchTweetsViewModel: TimelineTweetsProtocol {
  let query: String
  let userID: String
  let queryBuilder: QueryBuilder

  @Published var errorHandle: ErrorHandle?
  @Published var timelines: Set<String>?
  @Published var loadingTweet: Bool
  @Published var searchSettings: TimelineSearchSettings
  
  var paginationToken: String?
  var allTweets: [Sweet.TweetModel]
  var allUsers: [Sweet.UserModel]
  var allMedias: [Sweet.MediaModel]
  var allPolls: [Sweet.PollModel]
  var allPlaces: [Sweet.PlaceModel]
  

  init(userID: String, query: String, queryBuilder: QueryBuilder) {
    self.userID = userID
    self.query = query
    self.queryBuilder = queryBuilder
    
    self.allTweets = []
    self.allUsers = []
    self.allMedias = []
    self.allPolls = []
    self.allPlaces = []
    
    self.loadingTweet = false
    
    self.searchSettings = TimelineSearchSettings(query: "")
  }

  nonisolated static func == (lhs: SearchTweetsViewModel, rhs: SearchTweetsViewModel) -> Bool {
    lhs.userID == rhs.userID && lhs.query == rhs.query
  }

  nonisolated func hash(into hasher: inout Hasher) {
    hasher.combine(userID)
  }

  func fetchTweets(first firstTweetID: String?, last lastTweetID: String?) async
  {
    guard !loadingTweet else { return }

    loadingTweet.toggle()
    defer { loadingTweet.toggle() }
    
    let removeWhiteSpaceQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)

    if removeWhiteSpaceQuery.isEmpty {
      timelines = []
      return
    }

    do {
      let response = try await Sweet(userID: userID).searchRecentTweet(
        query: "\(removeWhiteSpaceQuery) \(queryBuilder.query)",
        nextToken: lastTweetID != nil ? paginationToken : nil
      )

      paginationToken = response.meta?.nextToken

      addResponse(response: response)

      addTimelines(response.tweets.map(\.id))
    } catch {
      let errorHandle = ErrorHandle(error: error)
      errorHandle.log()
      self.errorHandle = errorHandle
    }
  }
}
