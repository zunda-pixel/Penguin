//
//  TweetWidgets.swift
//

import WidgetKit
import SwiftUI
import PenguinKit
import Sweet

struct TweetWidgets: Widget {
  var body: some WidgetConfiguration {
    IntentConfiguration(
      kind: "com.zunda.tweet",
      intent: TweetConfigurationIntent.self,
      provider: TweetStatusProvider()
    ) { entry in
      TweetStatusView(entry: entry)
    }
    .configurationDisplayName("Tweet")
    .description("Shows an overview of your latest timeline")
    .supportedFamilies([
      .systemSmall,
      .systemMedium,
      .systemLarge,
      .systemExtraLarge,
      .accessoryRectangular,
      .accessoryInline,
    ])
  }
}

struct TweetStatusProvider: IntentTimelineProvider {
  typealias Entry = TweetStatusEntry
  typealias Intent = TweetConfigurationIntent

  func placeholder(in context: Context) -> TweetStatusEntry {
    let state: TweetWidgetState = Secure.currentUser == nil ? .notLoggedIn : .loading

    return TweetStatusEntry(date: .now, state: state)
  }

  func getSnapshot(
    for configuration: TweetConfigurationIntent,
    in context: Context,
    completion: @escaping (TweetStatusEntry) -> Void
  ) {
    guard let userID = configuration.user?.identifier ?? Secure.currentUser?.id else {
      completion(.init(date: .now, state: .notLoggedIn))
      return
    }

    Task {
      do {
        let response = try await Sweet(userID: userID).reverseChronological(
          userID: userID,
          maxResults: 10
        )
        guard let tweet = response.tweets.first else { return }
        let user = response.users.first { $0.id == tweet.authorID }!

        let entry = TweetStatusEntry(
          date: .now,
          state: .loggedIn(model: TweetWidgetModel(tweet: tweet, user: user))
        )

        completion(entry)
      } catch {
        let errorHandle = ErrorHandle(error: error)
        errorHandle.log()
      }
    }
  }

  func getTimeline(
    for configuration: TweetConfigurationIntent,
    in context: Context,
    completion: @escaping (WidgetKit.Timeline<TweetStatusEntry>) -> Void
  ) {
    guard let userID = configuration.user?.identifier ?? Secure.currentUser?.id else {
      let entry: WidgetKit.Timeline<TweetStatusEntry> = .init(entries: [.init(date: .now, state: .notLoggedIn)], policy: .atEnd)
      completion(entry)
      return
    }

    Task {
      do {
        let response = try await Sweet(userID: userID).reverseChronological(
          userID: userID,
          maxResults: 10
        )
        guard let tweet = response.tweets.first else { return }

        let user = response.users.first { $0.id == tweet.authorID }!

        let entry = TweetStatusEntry(
          date: .now,
          state: .loggedIn(model: .init(tweet: tweet, user: user))
        )

        let timeline = Timeline(
          entries: [entry],
          policy: .atEnd
        )

        completion(timeline)
      } catch {
        let errorHandle = ErrorHandle(error: error)
        errorHandle.log()
      }
    }
  }
}
