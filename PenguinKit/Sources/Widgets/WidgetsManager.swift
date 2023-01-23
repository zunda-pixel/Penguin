//
//  WidgetsManager.swift
//

#if canImport(ActivityKit)
import ActivityKit
import Foundation
import Sweet

enum WidgetsManager {
  static func fetchLatestTweet(userID: String) async throws -> Activity<TweetAttributes>? {
    guard ActivityAuthorizationInfo().areActivitiesEnabled else { return nil }

    let response = try await Sweet(userID: userID).reverseChronological(
      userID: userID,
      maxResults: 10
    )

    guard let latestTweet = response.tweets.first else { return nil }

    let author = response.users.first { $0.id == latestTweet.authorID }!

    for activity in Activity<TweetAttributes>.activities {
      await activity.end(nil, dismissalPolicy: .immediate)
    }

    let tweet = TweetAttributes(user: author, tweet: latestTweet)

    let activity = try Activity<TweetAttributes>.request(
      attributes: tweet,
      content: .init(state: .init(), staleDate: nil)
    )

    return activity
  }
}
#endif
