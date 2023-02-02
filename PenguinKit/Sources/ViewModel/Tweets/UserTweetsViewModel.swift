//
//  UserTweetsViewModel.swift
//

import Algorithms
import Foundation
import Sweet

final class UserTweetsViewModel: TimelineTweetsProtocol {
  func fetchTweets(first firstTweetID: String?, last lastTweetID: String?) async {
    guard !loadingTweet else { return }

    loadingTweet.toggle()
    defer { loadingTweet.toggle() }

    do {
      let response = try await Sweet(userID: userID).timeLine(
        userID: targetUserID,
        untilID: lastTweetID,
        sinceID: firstTweetID
      )

      addResponse(response: response)

      let quotedQuotedTweetIDs = response.relatedTweets.lazy.flatMap(\.referencedTweets)
        .filter { $0.type == .quoted }
        .map(\.id)

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

  static func == (lhs: UserTweetsViewModel, rhs: UserTweetsViewModel) -> Bool {
    rhs.userID == rhs.userID && rhs.targetUserID == rhs.targetUserID
  }

  func hash(into hasher: inout Hasher) {
    hasher.combine(userID)
    hasher.combine(targetUserID)
  }

  let userID: String
  let targetUserID: String

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

  init(viewModel: UserDetailViewModel) {
    self.userID = viewModel.userID
    self.targetUserID = viewModel.user.id
    self.loadingTweet = false

    self.allTweets = viewModel.allTweets
    self.allUsers = viewModel.allUsers
    self.allMedias = viewModel.allMedias
    self.allPolls = viewModel.allPolls
    self.allPlaces = viewModel.allPlaces

    self.timelines = viewModel.timelines

    self.searchSettings = TimelineSearchSettings(query: "")
  }
}
