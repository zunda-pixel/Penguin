//
//  LikesViewModel.swift
//

import Foundation
import Sweet

@MainActor final class LikesViewModel: TimelineTweetsProtocol {
  nonisolated static func == (lhs: LikesViewModel, rhs: LikesViewModel) -> Bool {
    lhs.userID == rhs.userID && lhs.ownerID == rhs.ownerID
  }

  nonisolated func hash(into hasher: inout Hasher) {
    hasher.combine(userID)
    hasher.combine(ownerID)
  }
  
  @Published var loadingTweet: Bool = false
  @Published var errorHandle: ErrorHandle?
  @Published var timelines: Set<String>?

  let userID: String
  let ownerID: String

  var paginationToken: String?

  var allTweets: [Sweet.TweetModel] = []
  var allUsers: [Sweet.UserModel] = []
  var allMedias: [Sweet.MediaModel] = []
  var allPolls: [Sweet.PollModel] = []
  var allPlaces: [Sweet.PlaceModel] = []

  func fetchTweets(first firstTweetID: String?, last lastTweetID: String?) async
  {
    guard !loadingTweet else { return }

    loadingTweet.toggle()
    defer { loadingTweet.toggle() }

    do {
      let response = try await Sweet(userID: userID).likedTweet(
        userID: ownerID,
        paginationToken: lastTweetID != nil ? paginationToken : nil
      )

      paginationToken = response.meta?.nextToken

      addResponse(response: response)

      addTimelines(response.tweets.map(\.id))
    } catch {
      errorHandle = ErrorHandle(error: error)
    }
  }

  init(userID: String, ownerID: String) {
    self.userID = userID
    self.ownerID = ownerID
  }
}
