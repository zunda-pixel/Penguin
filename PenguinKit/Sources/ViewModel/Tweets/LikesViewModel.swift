//
//  LikesViewModel.swift
//

import Algorithms
import Foundation
import Sweet

@MainActor final class LikesViewModel: TimelineTweetsProtocol {
  let userID: String
  let ownerID: String

  var paginationToken: String?

  var allTweets: Set<Sweet.TweetModel>
  var allUsers: Set<Sweet.UserModel>
  var allMedias: Set<Sweet.MediaModel>
  var allPolls: Set<Sweet.PollModel>
  var allPlaces: Set<Sweet.PlaceModel>

  @Published var reply: Reply?
  @Published var loadingTweet: Bool
  @Published var errorHandle: ErrorHandle?
  @Published var timelines: Set<String>?
  @Published var searchSettings: TimelineSearchSettings

  init(userID: String, ownerID: String) {
    self.userID = userID
    self.ownerID = ownerID

    self.loadingTweet = false

    self.allTweets = []
    self.allUsers = []
    self.allMedias = []
    self.allPolls = []
    self.allPlaces = []

    self.searchSettings = TimelineSearchSettings(query: "")
  }

  nonisolated static func == (lhs: LikesViewModel, rhs: LikesViewModel) -> Bool {
    lhs.userID == rhs.userID && lhs.ownerID == rhs.ownerID
  }

  nonisolated func hash(into hasher: inout Hasher) {
    hasher.combine(userID)
    hasher.combine(ownerID)
  }

  func fetchTweets(first firstTweetID: String?, last lastTweetID: String?) async {
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

      let quotedQuotedTweetIDs = response.relatedTweets.flatMap(\.referencedTweets).map(\.id)

      let ids = quotedQuotedTweetIDs + response.relatedTweets.map(\.id)

      let responses = try await Sweet(userID: userID).tweets(ids: Set(ids))

      for response in responses {
        addResponse(response: response)
      }

      addTimelines(response.tweets.map(\.id))
    } catch {
      let errorHandle = ErrorHandle(error: error)
      errorHandle.log()
      self.errorHandle = errorHandle
    }
  }
}
