//
//  TweetWidgets.swift
//

import Sweet
import SwiftUI
import WidgetKit
import os

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

struct TweetStatusView: View {
  @Environment(\.widgetFamily) var widgetFamily

  let entry: TweetStatusEntry

  var body: some View {
    switch entry.state {
    case .notLoggedIn: Text("Login Twitter")
    case .loading: ProgressView()
    case .loggedIn(let model):
      Group {
        switch widgetFamily {
        case .systemSmall: SmallTweetStatusView(model: model)
        case .systemMedium: MediumTweetStatusView(model: model)
        case .systemLarge: LargeTweetStatusView(model: model)
        case .systemExtraLarge: ExtraLargeTweetStatusView(model: model)
        case .accessoryRectangular: RectangularTweetStatusView(model: model)
        case .accessoryInline: AccessoryInlineTweetStatusView(model: model)
        case .accessoryCircular: fatalError()
        @unknown default:
          fatalError()
        }
      }
      .widgetURL(URL(string: "penguin://")!.appending(queryItems: [.init(name: "tweetID", value: model.tweet.id)]))
    }
  }
}

enum TweetWidgetState {
  case loggedIn(model: TweetWidgetModel)
  case notLoggedIn
  case loading
}

struct TweetWidgetModel {
  let tweet: Sweet.TweetModel
  let user: Sweet.UserModel
}

struct TweetStatusEntry: TimelineEntry {
  var date: Date
  let state: TweetWidgetState
}

struct TweetStatusProvider: IntentTimelineProvider {
  typealias Entry = TweetStatusEntry
  typealias Intent = TweetConfigurationIntent

  func placeholder(in context: Context) -> TweetStatusEntry {
    let state: TweetWidgetState = Secure.currentUser == nil ? .notLoggedIn : .loading

    return .init(date: .now, state: state)
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
          state: .loggedIn(model: .init(tweet: tweet, user: user))
        )

        completion(entry)
      } catch {
        print(error)
      }
    }
  }

  func getTimeline(
    for configuration: TweetConfigurationIntent,
    in context: Context,
    completion: @escaping (Timeline<TweetStatusEntry>) -> Void
  ) {
    guard let userID = configuration.user?.identifier ?? Secure.currentUser?.id else {
      completion(.init(entries: [.init(date: .now, state: .notLoggedIn)], policy: .atEnd))
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
        Logger.main.error("\(error.localizedDescription)")
      }
    }
  }
}
