//
//  OnlineTweetDetailViewModel.swift
//

import Foundation
import Sweet

class OnlineTweetDetailViewModel: TweetsViewProtocol {
  let userID: String
  let tweetID: String
  
  init(userID: String, tweetID: String) {
    self.userID = userID
    self.tweetID = tweetID
  }
  
  var paginationToken: String?
  @Published var tweetNode: TweetNode?
  
  var allTweets: [Sweet.TweetModel] = []
  var allUsers: [Sweet.UserModel] = []
  var allMedias: [Sweet.MediaModel] = []
  var allPolls: [Sweet.PollModel] = []
  var allPlaces: [Sweet.PlaceModel] = []
  
  @Published var errorHandle: ErrorHandle?
  @Published var loadingTweet = false
  
  nonisolated static func == (lhs: OnlineTweetDetailViewModel, rhs: OnlineTweetDetailViewModel) -> Bool {
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
      
      let sortedTweets = allTweets.lazy.sorted(by: \.createdAt!)
      
      let topTweet = sortedTweets
        .filter { $0.conversationID! == conversationID }
        .first { $0.referencedType != .reply }
      
      var tweetNode = TweetNode(id: (topTweet ?? sortedTweets.first!).id)
      var sources: Set<TweetNodeSource> = []
      
      for tweet in allTweets {
        for referencedTweet in tweet.referencedTweets where referencedTweet.type != .retweeted  {
          let source = TweetNodeSource(id: tweet.id, parentID: referencedTweet.id)
          sources.insert(source)
        }
      }
      
      tweetNode.setAllData(sources: Array(sources))
      
      self.tweetNode = tweetNode
    } catch {
      self.errorHandle = ErrorHandle(error: error)
    }
  }
}
