//
//  UserMentionsViewModel.swift
//

import Algorithms
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
  @Published var reply: Reply?

  var allTweets: Set<Sweet.TweetModel>
  var allUsers: Set<Sweet.UserModel>
  var allMedias: Set<Sweet.MediaModel>
  var allPolls: Set<Sweet.PollModel>
  var allPlaces: Set<Sweet.PlaceModel>

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

      let tweetIDs1 = response.relatedTweets.lazy.flatMap(\.referencedTweets)
        .filter { $0.type == .quoted }
        .map(\.id)

      let tweetIDs2 = response.relatedTweets.lazy
        .filter { tweet in
          let ids = tweet.attachments?.mediaKeys ?? []
          return !ids.allSatisfy(response.medias.map(\.id).contains)
        }
        .map(\.id)

      let tweetIDs = Array(chain(tweetIDs1, tweetIDs2).uniqued())

      if !tweetIDs.isEmpty {
        let response = try await Sweet(userID: userID).tweets(by: tweetIDs)
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
