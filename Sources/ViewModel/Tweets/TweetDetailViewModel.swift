//
//  TweetDetailViewModel.swift
//

import Foundation
import Sweet

final class TweetDetailViewModel: TweetsViewProtocol {
  let userID: String
  let cellViewModel: TweetCellViewModel

  var paginationToken: String?

  var allTweets: [Sweet.TweetModel]
  var allUsers: [Sweet.UserModel]
  var allMedias: [Sweet.MediaModel]
  var allPolls: [Sweet.PollModel]
  var allPlaces: [Sweet.PlaceModel]

  @Published var errorHandle: ErrorHandle?
  @Published var loadingTweet: Bool
  @Published var tweetNode: TweetNode?
  
  init(cellViewModel: TweetCellViewModel) {
    self.cellViewModel = cellViewModel
    self.userID = cellViewModel.userID
    
    self.loadingTweet = false
    
    self.allTweets = []
    self.allUsers = []
    self.allMedias = []
    self.allPolls = []
    self.allPlaces = []
    

    addResource(cellViewModel: cellViewModel)
  }

  func addResource(cellViewModel: TweetCellViewModel) {
    let tweets = [
      cellViewModel.tweet,
      cellViewModel.retweet?.tweet,
      cellViewModel.quoted?.tweet
    ].compactMap { $0 }
    
    tweets.forEach {
      allTweets.appendOrUpdate($0)
    }

    let users = [
      cellViewModel.author,
      cellViewModel.retweet?.user,
      cellViewModel.quoted?.user
    ].compactMap { $0 }
      
    users.forEach {
      allUsers.appendOrUpdate($0)
    }

    cellViewModel.medias.forEach {
      allMedias.appendOrUpdate($0)
    }

    let polls = [cellViewModel.poll].compactMap { $0 }
    polls.forEach {
      allPolls.appendOrUpdate($0)
    }

    let places = [cellViewModel.place].compactMap { $0 }
    places.forEach {
      allPlaces.appendOrUpdate($0)
    }
  }

  nonisolated static func == (lhs: TweetDetailViewModel, rhs: TweetDetailViewModel) -> Bool {
    lhs.cellViewModel == rhs.cellViewModel
  }

  nonisolated func hash(into hasher: inout Hasher) {
    cellViewModel.hash(into: &hasher)
  }

  func fetchTweets(first firstTweetID: String?, last lastTweetID: String?) async
  {
    guard !loadingTweet else { return }

    loadingTweet.toggle()
    defer { loadingTweet.toggle() }

    let conversationID = cellViewModel.tweetText.conversationID!
    
    do {
      let query = "conversation_id:\(conversationID)"

      let response = try await Sweet(userID: cellViewModel.userID).searchRecentTweet(
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
