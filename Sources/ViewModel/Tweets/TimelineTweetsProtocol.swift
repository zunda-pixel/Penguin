//
//  TimelineTweetsProtocol.swift
//

import Foundation
import Sweet

@MainActor protocol TimelineTweetsProtocol: TweetsViewProtocol {
  var showTweets: [Sweet.TweetModel] { get }
  var timelines: Set<String>? { get set }
  var paginationToken: String? { get }
}

extension TimelineTweetsProtocol {
  var showTweets: [Sweet.TweetModel] {
    return timelines?.lazy.map { timeline in
      self.allTweets.first(where: { $0.id == timeline })!
    }.sorted(by: { $0.createdAt! > $1.createdAt! }) ?? []
  }

  func addTimelines(_ tweetIDs: [String]) {
    if timelines == nil {
      timelines = Set(tweetIDs)
    } else {
      timelines = timelines!.union(tweetIDs)
    }
  }
}
