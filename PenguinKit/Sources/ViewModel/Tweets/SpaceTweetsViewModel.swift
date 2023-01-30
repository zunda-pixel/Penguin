import Algorithms
import Foundation
import Sweet

@MainActor final class SpaceTweetsViewModel: TimelineTweetsProtocol {
  let userID: String
  let spaceID: String

  var paginationToken: String?

  var allTweets: Set<Sweet.TweetModel>
  var allUsers: Set<Sweet.UserModel>
  var allMedias: Set<Sweet.MediaModel>
  var allPolls: Set<Sweet.PollModel>
  var allPlaces: Set<Sweet.PlaceModel>

  @Published var errorHandle: ErrorHandle?
  @Published var timelines: Set<String>?
  @Published var loadingTweet: Bool
  @Published var searchSettings: TimelineSearchSettings
  @Published var reply: Reply?

  init(userID: String, spaceID: String) {
    self.userID = userID
    self.spaceID = spaceID

    self.loadingTweet = false

    self.allTweets = []
    self.allUsers = []
    self.allMedias = []
    self.allPolls = []
    self.allPlaces = []

    self.searchSettings = TimelineSearchSettings(query: "")
  }

  nonisolated static func == (lhs: SpaceTweetsViewModel, rhs: SpaceTweetsViewModel) -> Bool {
    lhs.userID == rhs.userID && lhs.spaceID == rhs.spaceID
  }

  nonisolated func hash(into hasher: inout Hasher) {
    hasher.combine(userID)
    hasher.combine(spaceID)
  }

  func fetchTweets(first firstTweetID: String?, last lastTweetID: String?) async {
    guard !loadingTweet else { return }

    loadingTweet.toggle()
    defer { loadingTweet.toggle() }

    do {
      let response = try await Sweet(userID: userID).spaceTweets(spaceID: spaceID)

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
