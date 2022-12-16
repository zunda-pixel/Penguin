//
//  ListDetailViewModel.swift
//

import Foundation
import Sweet

@MainActor final class ListDetailViewModel: TimelineTweetsProtocol {
  nonisolated static func == (lhs: ListDetailViewModel, rhs: ListDetailViewModel) -> Bool {
    lhs.userID == rhs.userID && lhs.list == rhs.list
  }
  
  nonisolated func hash(into hasher: inout Hasher) {
    hasher.combine(userID)
    hasher.combine(list)
  }
  
  var paginationToken: String?
  @Published var errorHandle: ErrorHandle?
  @Published var timelines: Set<String>?

  let list: Sweet.ListModel
  let userID: String

  @Published var loadingTweet: Bool = false

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
      let response = try await Sweet(userID: userID).listTweets(
        listID: list.id,
        paginationToken: lastTweetID != nil ? paginationToken : nil
      )

      paginationToken = response.meta?.nextToken

      addResponse(response: response)

      addTimelines(response.tweets.map(\.id))

      if let firstTweetID,
         !response.tweets.isEmpty {
        await fetchTweets(first: firstTweetID, last: nil)
        return
      }
    } catch {
      errorHandle = ErrorHandle(error: error)
    }
  }

  init(userID: String, list: Sweet.ListModel) {
    self.userID = userID
    self.list = list
  }
}
