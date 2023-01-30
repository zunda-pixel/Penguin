import Algorithms
import Foundation
import Sweet

@MainActor final class QuoteTweetsViewModel: TimelineTweetsProtocol {
  let userID: String
  let sourceTweetID: String

  var paginationToken: String?
  var allTweets: Set<Sweet.TweetModel>
  var allUsers: Set<Sweet.UserModel>
  var allMedias: Set<Sweet.MediaModel>
  var allPolls: Set<Sweet.PollModel>
  var allPlaces: Set<Sweet.PlaceModel>

  @Published var reply: Reply?
  @Published var errorHandle: ErrorHandle?
  @Published var timelines: Set<String>?
  @Published var loadingTweet: Bool
  @Published var searchSettings: TimelineSearchSettings

  init(userID: String, source sourceTweetID: String) {
    self.userID = userID
    self.sourceTweetID = sourceTweetID

    self.loadingTweet = false

    self.allTweets = []
    self.allUsers = []
    self.allMedias = []
    self.allPolls = []
    self.allPlaces = []

    self.searchSettings = TimelineSearchSettings(query: "")
  }

  nonisolated static func == (lhs: QuoteTweetsViewModel, rhs: QuoteTweetsViewModel) -> Bool {
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
      let response = try await Sweet(userID: userID).quoteTweets(
        source: sourceTweetID,
        paginationToken: lastTweetID != nil ? paginationToken : nil
      )

      paginationToken = response.meta?.nextToken

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
