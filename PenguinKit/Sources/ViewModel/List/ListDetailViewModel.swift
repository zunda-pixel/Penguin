//
//  ListDetailViewModel.swift
//

import Algorithms
import Foundation
import Sweet

@MainActor final class ListDetailViewModel: TimelineTweetsProtocol {
  @Published var errorHandle: ErrorHandle?
  @Published var timelines: Set<String>?
  @Published var loadingTweet: Bool
  @Published var searchSettings: TimelineSearchSettings
  @Published var reply: Reply?

  let list: Sweet.ListModel
  let userID: String

  var paginationToken: String?

  var allTweets: Set<Sweet.TweetModel>
  var allUsers: Set<Sweet.UserModel>
  var allMedias: Set<Sweet.MediaModel>
  var allPolls: Set<Sweet.PollModel>
  var allPlaces: Set<Sweet.PlaceModel>

  init(userID: String, list: Sweet.ListModel) {
    self.userID = userID
    self.list = list

    self.allTweets = []
    self.allUsers = []
    self.allMedias = []
    self.allPolls = []
    self.allPlaces = []

    self.loadingTweet = false

    self.searchSettings = TimelineSearchSettings(query: "")
  }

  nonisolated static func == (lhs: ListDetailViewModel, rhs: ListDetailViewModel) -> Bool {
    lhs.userID == rhs.userID && lhs.list == rhs.list
  }

  nonisolated func hash(into hasher: inout Hasher) {
    hasher.combine(userID)
    hasher.combine(list)
  }

  func fetchTweets(first firstTweetID: String?, last lastTweetID: String?) async {
    guard !loadingTweet else { return }

    loadingTweet.toggle()
    defer { loadingTweet.toggle() }

    do {
      let response = try await Sweet(userID: userID).listTweets(
        listID: list.id,
        paginationToken: lastTweetID != nil ? paginationToken : nil
      )

      paginationToken = response.meta?.nextToken

      let quotedQuotedTweetIDs = response.relatedTweets.flatMap(\.referencedTweets).map(\.id)

      let ids = quotedQuotedTweetIDs + response.relatedTweets.map(\.id)

      let responses = try await Sweet(userID: userID).tweets(ids: Set(ids))

      for response in responses {
        addResponse(response: response)
      }

      addResponse(response: response)

      addTimelines(response.tweets.map(\.id))

      if let firstTweetID,
        !response.tweets.isEmpty
      {
        await fetchTweets(first: firstTweetID, last: nil)
        return
      }
    } catch {
      let errorHandle = ErrorHandle(error: error)
      errorHandle.log()
      self.errorHandle = errorHandle
    }
  }
}
