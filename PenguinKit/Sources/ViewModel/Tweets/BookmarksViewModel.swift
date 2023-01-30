//
//  BookmarksViewModel.swift
//

import Foundation
import Sweet

@MainActor final class BookmarksViewModel: TimelineTweetsProtocol {
  let userID: String

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

  init(userID: String) {
    self.userID = userID

    self.allTweets = []
    self.allUsers = []
    self.allMedias = []
    self.allPolls = []
    self.allPlaces = []

    self.loadingTweet = false

    self.searchSettings = TimelineSearchSettings(query: "")
  }

  nonisolated static func == (lhs: BookmarksViewModel, rhs: BookmarksViewModel) -> Bool {
    lhs.userID == rhs.userID
  }

  nonisolated func hash(into hasher: inout Hasher) {
    hasher.combine(userID)
  }

  func fetchTweets(first firstTweetID: String?, last lastTweetID: String?) async {
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

      let tweetIDs1 = response.relatedTweets.lazy
        .flatMap(\.referencedTweets).filter { $0.type == .quoted }
        .map(\.id)

      let tweetIDs2 = response.relatedTweets.lazy
        .filter { tweet in
          let ids = tweet.attachments?.mediaKeys ?? []
          return !ids.allSatisfy(response.medias.map(\.id).contains)
        }
        .map(\.id)
      
      let tweetIDs = Array(tweetIDs1) + Array(tweetIDs2)
      
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
