//
//  TimelineTweetsProtocol.swift
//

import Foundation
import Sweet

@MainActor protocol TimelineTweetsProtocol: TweetsViewProtocol {
  var showTweets: [Sweet.TweetModel] { get }
  var timelines: Set<String>? { get set }
  var paginationToken: String? { get }
  var searchSettings: TimelineSearchSettings { get set }
}

extension TimelineTweetsProtocol {
  var showTweets: [Sweet.TweetModel] {
    let tweets = timelines?.lazy.map { timeline in
      self.allTweets.first(where: { $0.id == timeline })!
    }.sorted(by: \.id, isAscending: false)

    if searchSettings.query.isEmpty {
      return tweets ?? []
    } else {
      return tweets?.filter {
        $0.tweetText.lowercased().contains(self.searchSettings.query.lowercased())
      } ?? []
    }
  }

  func addTimelines(_ tweetIDs: [String]) {
    if timelines == nil {
      timelines = Set(tweetIDs)
    } else {
      timelines = timelines!.union(tweetIDs)
    }
  }
}

struct TimelineSearchSettings {
  var query: String
}
