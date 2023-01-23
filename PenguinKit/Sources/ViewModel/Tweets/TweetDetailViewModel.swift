//
//  TweetDetailViewModel.swift
//

import Algorithms
import Foundation
import Sweet

final class TweetDetailViewModel: TweetsViewProtocol {
  let userID: String
  let cellViewModel: TweetCellViewModel

  var paginationToken: String?

  var allTweets: Set<Sweet.TweetModel>
  var allUsers: Set<Sweet.UserModel>
  var allMedias: Set<Sweet.MediaModel>
  var allPolls: Set<Sweet.PollModel>
  var allPlaces: Set<Sweet.PlaceModel>

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
      cellViewModel.quoted?.tweetContent.tweet,
      cellViewModel.quoted?.quoted?.tweet,
    ].compacted()

    tweets.forEach {
      allTweets.insertOrUpdate($0, by: \.id)
    }

    let users = [
      cellViewModel.author,
      cellViewModel.retweet?.author,
      cellViewModel.quoted?.tweetContent.author,
      cellViewModel.quoted?.quoted?.author,
    ].compacted()

    users.forEach {
      allUsers.insertOrUpdate($0, by: \.id)
    }

    cellViewModel.medias.forEach {
      allMedias.insertOrUpdate($0, by: \.id)
    }

    let polls = [cellViewModel.poll].compacted()
    polls.forEach {
      allPolls.insertOrUpdate($0, by: \.id)
    }

    let places = [cellViewModel.place].compacted()
    places.forEach {
      allPlaces.insertOrUpdate($0, by: \.id)
    }
  }

  nonisolated static func == (lhs: TweetDetailViewModel, rhs: TweetDetailViewModel) -> Bool {
    lhs.cellViewModel == rhs.cellViewModel
  }

  nonisolated func hash(into hasher: inout Hasher) {
    cellViewModel.hash(into: &hasher)
  }

  func fetchTweets(first firstTweetID: String?, last lastTweetID: String?) async {
    guard !loadingTweet else { return }

    loadingTweet.toggle()
    defer { loadingTweet.toggle() }

    let conversationID = cellViewModel.tweetText.conversationID!

    do {
      let tweetResponse = try await Sweet(userID: cellViewModel.userID).tweets(by: [
        cellViewModel.tweetText.id
      ])
      addResponse(response: tweetResponse)

      let query = "conversation_id:\(conversationID)"

      let response = try await Sweet(userID: cellViewModel.userID).searchRecentTweet(
        query: query,
        nextToken: lastTweetID != nil ? paginationToken : nil
      )

      paginationToken = response.meta?.nextToken

      addResponse(response: response)

      let tweetIDs1 = tweetResponse.relatedTweets.lazy.flatMap(\.referencedTweets).filter {
        $0.type == .quoted
      }.map(\.id)
      let tweetIDs2 = response.relatedTweets.lazy.flatMap(\.referencedTweets).filter {
        $0.type == .quoted
      }.map(\.id)

      let tweetIDs = Array(chain(tweetIDs1, tweetIDs2).uniqued())

      if !tweetIDs.isEmpty {
        let response = try await Sweet(userID: userID).tweets(by: tweetIDs)
        addResponse(response: response)
      }

      let sortedTweets = allTweets.lazy.sorted(by: \.createdAt!)

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
