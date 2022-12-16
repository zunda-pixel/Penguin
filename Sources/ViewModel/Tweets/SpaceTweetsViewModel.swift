import Foundation
import Sweet

@MainActor final class SpaceTweetsViewModel: TimelineTweetsProtocol {
  nonisolated static func == (lhs: SpaceTweetsViewModel, rhs: SpaceTweetsViewModel) -> Bool {
    lhs.userID == rhs.userID && lhs.spaceID == rhs.spaceID
  }

  nonisolated func hash(into hasher: inout Hasher) {
    hasher.combine(userID)
    hasher.combine(spaceID)
  }

  @Published var errorHandle: ErrorHandle?
  @Published var timelines: Set<String>?

  let userID: String
  let spaceID: String

  var paginationToken: String?
  
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
      let response = try await Sweet(userID: userID).spaceTweets(spaceID: spaceID)

      addResponse(response: response)

      addTimelines(response.tweets.map(\.id))
    } catch {
      errorHandle = ErrorHandle(error: error)
    }
  }

  init(userID: String, spaceID: String) {
    self.userID = userID
    self.spaceID = spaceID
  }
}
