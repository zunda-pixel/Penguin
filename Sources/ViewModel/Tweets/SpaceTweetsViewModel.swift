import Foundation
import Sweet

@MainActor final class SpaceTweetsViewModel: TimelineTweetsProtocol {
  let userID: String
  let spaceID: String

  var paginationToken: String?
  
  var allTweets: [Sweet.TweetModel]
  var allUsers: [Sweet.UserModel]
  var allMedias: [Sweet.MediaModel]
  var allPolls: [Sweet.PollModel]
  var allPlaces: [Sweet.PlaceModel]
  
  @Published var errorHandle: ErrorHandle?
  @Published var timelines: Set<String>?
  @Published var loadingTweet: Bool
  
  init(userID: String, spaceID: String) {
    self.userID = userID
    self.spaceID = spaceID
    
    self.loadingTweet = false
    
    self.allTweets = []
    self.allUsers = []
    self.allMedias = []
    self.allPolls = []
    self.allPlaces = []
  }
  
  nonisolated static func == (lhs: SpaceTweetsViewModel, rhs: SpaceTweetsViewModel) -> Bool {
    lhs.userID == rhs.userID && lhs.spaceID == rhs.spaceID
  }

  nonisolated func hash(into hasher: inout Hasher) {
    hasher.combine(userID)
    hasher.combine(spaceID)
  }

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
}
