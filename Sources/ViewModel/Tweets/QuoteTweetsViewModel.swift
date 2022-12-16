import Foundation
import Sweet

@MainActor final class QuoteTweetsViewModel: TimelineTweetsProtocol {
  nonisolated static func == (lhs: QuoteTweetsViewModel, rhs: QuoteTweetsViewModel) -> Bool {
    lhs.userID == rhs.userID
  }

  nonisolated func hash(into hasher: inout Hasher) {
    hasher.combine(userID)
  }

  var paginationToken: String?
  @Published var errorHandle: ErrorHandle?
  @Published var timelines: Set<String>?

  let userID: String
  let sourceTweetID: String

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
      let response = try await Sweet(userID: userID).quoteTweets(
        source: sourceTweetID,
        paginationToken: lastTweetID != nil ? paginationToken : nil
      )

      paginationToken = response.meta?.nextToken

      addResponse(response: response)

      addTimelines(response.tweets.map(\.id))
    } catch {
      errorHandle = ErrorHandle(error: error)
    }
  }

  init(userID: String, source sourceTweetID: String) {
    self.userID = userID
    self.sourceTweetID = sourceTweetID
  }
}
