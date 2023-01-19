//
//  UserDetailViewModel.swift
//

import Foundation
import Sweet

@MainActor final class UserDetailViewModel: TimelineTweetsProtocol {
  let userID: String
  let user: Sweet.UserModel

  var paginationToken: String?

  var allTweets: [Sweet.TweetModel]
  var allUsers: [Sweet.UserModel]
  var allMedias: [Sweet.MediaModel]
  var allPolls: [Sweet.PollModel]
  var allPlaces: [Sweet.PlaceModel]

  @Published var loadingTweet: Bool
  @Published var errorHandle: ErrorHandle?
  @Published var pinnedTweetID: String?
  @Published var timelines: Set<String>?
  @Published var searchSettings: TimelineSearchSettings

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

      allTweets.appendOrUpdate(response.tweet)

      response.relatedTweets.forEach {
        allTweets.appendOrUpdate($0)
      }

      response.medias.forEach {
        allMedias.appendOrUpdate($0)
      }

      response.places.forEach {
        allPlaces.appendOrUpdate($0)
      }

      response.users.forEach {
        allUsers.appendOrUpdate($0)
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

      let tweetIDs = Array(
        response.relatedTweets.lazy.flatMap(\.referencedTweets).filter { $0.type == .quoted }.map(
          \.id
        ).uniqued())

      if !tweetIDs.isEmpty {
        let response = try await Sweet(userID: userID).tweets(by: tweetIDs)
        addResponse(response: response)
      }

      // TODO need to be empty?
      timelines = []

      addTimelines(response.tweets.map(\.id))
    } catch {
      let errorHandle = ErrorHandle(error: error)
      errorHandle.log()
      self.errorHandle = errorHandle
    }
  }
}
