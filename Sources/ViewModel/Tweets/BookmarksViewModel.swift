//
//  BookmarksViewModel.swift
//

import Foundation
import Sweet

@MainActor final class BookmarksViewModel: TimelineTweetsProtocol {
  let userID: String
  
  var paginationToken: String?

  var allTweets: [Sweet.TweetModel]
  var allUsers: [Sweet.UserModel]
  var allMedias: [Sweet.MediaModel]
  var allPolls: [Sweet.PollModel]
  var allPlaces: [Sweet.PlaceModel]
  
  @Published var loadingTweet: Bool
  @Published var errorHandle: ErrorHandle?
  @Published var timelines: Set<String>?
  
  init(userID: String) {
    self.userID = userID
    
    self.allTweets = []
    self.allUsers = []
    self.allMedias = []
    self.allPolls = []
    self.allPlaces = []
    
    self.loadingTweet = false
  }
  
  nonisolated static func == (lhs: BookmarksViewModel, rhs: BookmarksViewModel) -> Bool {
    lhs.userID == rhs.userID
  }

  nonisolated func hash(into hasher: inout Hasher) {
    hasher.combine(userID)
  }
  
  func fetchTweets(first firstTweetID: String?, last lastTweetID: String?) async
  {
    guard !loadingTweet else { return }

    loadingTweet.toggle()
    defer { loadingTweet.toggle() }

    do {
      let response = try await Sweet(userID: userID).bookmarks(
        userID: userID,
        paginationToken: lastTweetID != nil ? paginationToken : nil
      )

      paginationToken = response.meta?.nextToken

      addResponse(response: response)

      addTimelines(response.tweets.map(\.id))
    } catch {
      errorHandle = ErrorHandle(error: error)
    }
  }
}
