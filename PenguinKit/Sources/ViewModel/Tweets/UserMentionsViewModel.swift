//
//  UserMentionsViewModel.swift
//

import Foundation
import Sweet

@MainActor final class UserMentionsViewModel: TimelineTweetsProtocol {
  let userID: String
  let ownerID: String

  var paginationToken: String?

  @Published var errorHandle: ErrorHandle?
  @Published var loadingTweet: Bool
  @Published var timelines: Set<String>?
  @Published var searchSettings: TimelineSearchSettings

  var allTweets: [Sweet.TweetModel]
  var allUsers: [Sweet.UserModel]
  var allMedias: [Sweet.MediaModel]
  var allPolls: [Sweet.PollModel]
  var allPlaces: [Sweet.PlaceModel]

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

  nonisolated static func == (lhs: UserMentionsViewModel, rhs: UserMentionsViewModel) -> Bool {
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
      let response = try await Sweet(userID: userID).mentions(
        userID: ownerID,
        untilID: lastTweetID,
        sinceID: firstTweetID
      )

      addResponse(response: response)

      let referencedTweetIDs = response.relatedTweets.lazy.flatMap(\.referencedTweets).filter({
        $0.type == .quoted
      }).map(\.id)

      if referencedTweetIDs.count > 0 {
        let referencedResponse = try await Sweet(userID: userID).tweets(
          by: Array(referencedTweetIDs)
        )

        addResponse(response: referencedResponse)
      }

      addTimelines(response.tweets.map(\.id))
    } catch {
      let errorHandle = ErrorHandle(error: error)
      errorHandle.log()
      self.errorHandle = errorHandle
    }
  }
}
