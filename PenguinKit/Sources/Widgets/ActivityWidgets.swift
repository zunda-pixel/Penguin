//
//  ActivityWidgets.swift
//

#if canImport(ActivityKit)
import ActivityKit
import SwiftUI
import WidgetKit

public struct ActivityWidgets: Widget {
  public init() {}

  public var body: some WidgetConfiguration {
    ActivityConfiguration(for: TweetAttributes.self) { context in
      TweetNotification(attributes: context.attributes)
        .widgetURL(
          URL(string: "penguin://")!.appending(queryItems: [
            .init(name: "tweetID", value: context.attributes.tweet.id)
          ])
        )
        .padding()
    } dynamicIsland: { context in
      DynamicIsland {
        DynamicIslandExpandedRegion(.leading) {
          Image(systemName: "person")
        }
        DynamicIslandExpandedRegion(.center) {
          VStack(alignment: .leading) {
            (Text(context.attributes.user.name).bold()
              + Text(" @\(context.attributes.user.userName)").foregroundColor(.secondary))
              .font(.title3)
            Text(context.attributes.tweet.createdAt!, format: .relative(presentation: .named))
          }
        }
        DynamicIslandExpandedRegion(.bottom) {
          Text(context.attributes.tweet.text)
            .fixedSize(horizontal: false, vertical: true)
            .lineLimit(2)
        }
      } compactLeading: {
        Text(context.attributes.user.name)
      } compactTrailing: {
        Text(context.attributes.tweet.createdAt!, format: .relative(presentation: .named))
      } minimal: {
        Text("🐧")
      }
      .widgetURL(
        URL(string: "penguin://")!.appending(queryItems: [
          .init(name: "tweetID", value: context.attributes.tweet.id)
        ]))
    }
    .configurationDisplayName("Latest Tweet")
    .description("This is Latest Tweet widget.")
  }
}
#endif
