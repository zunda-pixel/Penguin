//
//  UserDetailViewModel.swift
//

import Algorithms
import Foundation
import Sweet

@MainActor final class UserDetailViewModel: TimelineTweetsProtocol {
  let userID: String
  let user: Sweet.UserModel

  var paginationToken: String?

  var allTweets: Set<Sweet.TweetModel>
  var allUsers: Set<Sweet.UserModel>
  var allMedias: Set<Sweet.MediaModel>
  var allPolls: Set<Sweet.PollModel>
  var allPlaces: Set<Sweet.PlaceModel>

  @Published var loadingTweet: Bool
  @Published var errorHandle: ErrorHandle?
  @Published var pinnedTweetID: String?
  @Published var timelines: Set<String>?
  @Published var searchSettings: TimelineSearchSettings
  @Published var reply: Reply?

  init(userID: String, user: Sweet.UserModel) {
    self.userID = userID
    self.user = user
    self.loadingTweet = false

    self.allTweets = []
    self.allUsers = []
    self.allMedias = []
    self.allPolls = []
    self.allPlaces = []

    self.searchSettings = TimelineSearchSettings(query: "")
  }

  nonisolated static func == (lhs: UserDetailViewModel, rhs: UserDetailViewModel) -> Bool {
    lhs.userID == rhs.userID && lhs.user == rhs.user
  }

  nonisolated func hash(into hasher: inout Hasher) {
    hasher.combine(userID)
    hasher.combine(user)
  }

  func fetchPinnedTweet() async {
    guard let pinnedTweetID = user.pinnedTweetID else { return }

    do {
      let response = try await Sweet(userID: userID).tweet(by: pinnedTweetID)

      allTweets.insertOrUpdate(response.tweet, by: \.id)

      response.relatedTweets.forEach {
        allTweets.insertOrUpdate($0, by: \.id)
      }

      response.medias.forEach {
        allMedias.insertOrUpdate($0, by: \.id)
      }

      response.places.forEach {
        allPlaces.insertOrUpdate($0, by: \.id)
      }

      response.users.forEach {
        allUsers.insertOrUpdate($0, by: \.id)
      }

      response.polls.forEach {
        allPolls.insertOrUpdate($0, by: \.id)
      }

      self.pinnedTweetID = pinnedTweetID
    } catch {
      // TODO
      // Sweet.tweetでツイートが見つからなかった時のエラー対処法が今のところない
      // Sweetのアップデートが必要
      //      let errorHandle = ErrorHandle(error: error)
      //      errorHandle.log()
      //      self.errorHandle = errorHandle
    }
  }

  func fetchTweets(first firstTweetID: String?, last lastTweetID: String?) async {
    guard !loadingTweet else { return }

    loadingTweet.toggle()
    defer { loadingTweet.toggle() }

    do {
      let response = try await Sweet(userID: userID).timeLine(
        userID: user.id,
        untilID: lastTweetID,
        sinceID: firstTweetID
      )

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
