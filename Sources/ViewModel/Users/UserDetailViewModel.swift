//
//  UserDetailViewModel.swift
//

import Foundation
import Sweet

@MainActor final class UserDetailViewModel: TimelineTweetsProtocol {
  nonisolated static func == (lhs: UserDetailViewModel, rhs: UserDetailViewModel) -> Bool {
    lhs.userID == rhs.userID && lhs.user == rhs.user
  }

  nonisolated func hash(into hasher: inout Hasher) {
    hasher.combine(userID)
    hasher.combine(user)
  }

  let userID: String

  let user: Sweet.UserModel
  
  var paginationToken: String?

  @Published var loadingTweet: Bool = false

  @Published var errorHandle: ErrorHandle?
  @Published var pinnedTweetID: String?

  @Published var timelines: Set<String>?
  var allTweets: [Sweet.TweetModel] = []
  var allUsers: [Sweet.UserModel] = []
  var allMedias: [Sweet.MediaModel] = []
  var allPolls: [Sweet.PollModel] = []
  var allPlaces: [Sweet.PlaceModel] = []

  func fetchPinnedTweet() async {
    guard let pinnedTweetID = user.pinnedTweetID else { return }
    
    do {
      let response = try await Sweet(userID: userID).tweets(by: [pinnedTweetID])
      addResponse(response: response)
      
      self.pinnedTweetID = pinnedTweetID
    } catch {
      self.errorHandle = ErrorHandle(error: error)
    }
  }
  
  func fetchTweets(first firstTweetID: String?, last lastTweetID: String?) async
  {
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

      let referencedTweetIDs = response.relatedTweets.lazy.flatMap(\.referencedTweets).filter({
        $0.type == .quoted
      }).map(\.id)

      if referencedTweetIDs.count > 0 {
        let referencedResponse = try await Sweet(userID: userID).tweets(
          by: Array(referencedTweetIDs)
        )

        addResponse(response: referencedResponse)
      }

      timelines = []

      addTimelines(response.tweets.map(\.id))
    } catch {
      errorHandle = ErrorHandle(error: error)
    }
  }

  init(userID: String, user: Sweet.UserModel) {
    self.userID = userID
    self.user = user
  }
}
