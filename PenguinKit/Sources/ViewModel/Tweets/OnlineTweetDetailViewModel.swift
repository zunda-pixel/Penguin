//
//  OnlineTweetDetailViewModel.swift
//

import Algorithms
import Foundation
import Sweet

class OnlineTweetDetailViewModel: TweetsViewProtocol {
  let userID: String
  let tweetID: String

  var paginationToken: String?

  var allTweets: Set<Sweet.TweetModel>
  var allUsers: Set<Sweet.UserModel>
  var allMedias: Set<Sweet.MediaModel>
  var allPolls: Set<Sweet.PollModel>
  var allPlaces: Set<Sweet.PlaceModel>

  @Published var reply: Reply?
  @Published var tweetNode: TweetNode?
  @Published var errorHandle: ErrorHandle?
  @Published var loadingTweet: Bool

  init(userID: String, tweetID: String) {
    self.userID = userID
    self.tweetID = tweetID

    self.loadingTweet = false

    self.allTweets = []
    self.allUsers = []
    self.allMedias = []
    self.allPolls = []
    self.allPlaces = []
  }

  nonisolated static func == (lhs: OnlineTweetDetailViewModel, rhs: OnlineTweetDetailViewModel)
    -> Bool
  {
    lhs.userID == rhs.userID && lhs.tweetID == rhs.tweetID
  }

  nonisolated func hash(into hasher: inout Hasher) {
    hasher.combine(userID)
    hasher.combine(tweetID)
  }

  func fetchTweets(first firstTweetID: String?, last lastTweetID: String?) async {
    guard !loadingTweet else { return }

    loadingTweet.toggle()
    defer { loadingTweet.toggle() }

    do {
      let tweetResponse = try await Sweet(userID: userID).tweets(by: [tweetID])

      addResponse(response: tweetResponse)

      let conversationID = tweetResponse.tweets.first!.conversationID!

      let query = "conversation_id:\(conversationID)"

      let response = try await Sweet(userID: userID).searchRecentTweet(
        query: query,
        nextToken: lastTweetID != nil ? paginationToken : nil
      )

      paginationToken = response.meta?.nextToken

      addResponse(response: response)

      let relatedTweets = tweetResponse.relatedTweets + response.relatedTweets
      let medias = tweetResponse.medias + response.medias

      let tweetIDs1 = relatedTweets.lazy.flatMap(\.referencedTweets)
        .filter { $0.type == .quoted }
        .map(\.id)

      let tweetIDs2 = relatedTweets.lazy
        .filter { tweet in
          let ids = tweet.attachments?.mediaKeys ?? []
          return !ids.allSatisfy(medias.map(\.id).contains)
        }
        .map(\.id)

      let tweetIDs = Array(chain(tweetIDs1, tweetIDs2).uniqued())

      if !tweetIDs.isEmpty {
        let response = try await Sweet(userID: userID).tweets(by: tweetIDs)
        addResponse(response: response)
      }

      let sortedTweets = allTweets.sorted(by: \.createdAt!)

      let topTweet =
        sortedTweets
        .filter { $0.conversationID! == conversationID }
        .first { $0.referencedType != .reply }

      var tweetNode = TweetNode(id: (topTweet ?? sortedTweets.first!).id)
      var sources: Set<TweetNodeSource> = []

      for tweet in allTweets {
        for referencedTweet in tweet.referencedTweets where referencedTweet.type != .retweeted {
          let source = TweetNodeSource(id: tweet.id, parentID: referencedTweet.id)
          sources.insert(source)
        }
      }

      tweetNode.setAllData(sources: Array(sources))

      self.tweetNode = tweetNode
    } catch {
      let errorHandle = ErrorHandle(error: error)
      errorHandle.log()
      self.errorHandle = errorHandle
    }
  }
}
