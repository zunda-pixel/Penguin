import Foundation
import Sweet

@MainActor final class RepliesTweetsViewModel: TimelineTweetsProtocol {
  let userID: String
  let conversationID: String

  var paginationToken: String?

  var allTweets: [Sweet.TweetModel]
  var allUsers: [Sweet.UserModel]
  var allMedias: [Sweet.MediaModel]
  var allPolls: [Sweet.PollModel]
  var allPlaces: [Sweet.PlaceModel]

  @Published var errorHandle: ErrorHandle?
  @Published var loadingTweet: Bool
  @Published var timelines: Set<String>?
  @Published var searchSettings: TimelineSearchSettings

  var showTweets: [Sweet.TweetModel] {
    return timelines?.map { timeline in
      allTweets.first(where: { $0.id == timeline })!
    }.lazy.sorted(by: { $0.createdAt! < $1.createdAt! }) ?? []
  }

  init(userID: String, conversationID: String) {
    self.userID = userID
    self.conversationID = conversationID

    self.loadingTweet = false

    self.allTweets = []
    self.allUsers = []
    self.allMedias = []
    self.allPolls = []
    self.allPlaces = []

    self.searchSettings = TimelineSearchSettings(query: "")
  }

  nonisolated static func == (lhs: RepliesTweetsViewModel, rhs: RepliesTweetsViewModel) -> Bool {
    lhs.userID == rhs.userID && lhs.conversationID == rhs.conversationID
  }

  nonisolated func hash(into hasher: inout Hasher) {
    hasher.combine(userID)
    hasher.combine(conversationID)
  }

  func fetchTweets(first firstTweetID: String?, last lastTweetID: String?) async {
    guard !loadingTweet else { return }

    loadingTweet.toggle()
    defer { loadingTweet.toggle() }

    do {
      let query = "conversation_id:\(conversationID)"

      let response = try await Sweet(userID: userID).searchRecentTweet(
        query: query,
        nextToken: lastTweetID != nil ? paginationToken : nil
      )

      paginationToken = response.meta?.nextToken

      addResponse(response: response)
      
      let tweetIDs = Array(response.relatedTweets.lazy.flatMap(\.referencedTweets).filter { $0.type == .quoted }.map(\.id).uniqued())
            
      if !tweetIDs.isEmpty {
        let response = try await Sweet(userID: userID).tweets(by: tweetIDs)
        addResponse(response: response)
      }

      addTimelines(response.relatedTweets.map(\.id))
      addTimelines(response.tweets.map(\.id))
    } catch {
      let errorHandle = ErrorHandle(error: error)
      errorHandle.log()
      self.errorHandle = errorHandle
    }
  }
}
