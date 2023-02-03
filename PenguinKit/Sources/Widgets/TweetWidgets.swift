//
//  TweetWidgets.swift
//

import Sweet
import SwiftUI
import WidgetKit

public enum TweetWidgetState {
  case loggedIn(model: TweetWidgetModel)
  case notLoggedIn
  case loading
}

public struct TweetWidgetModel {
  let tweet: Sweet.TweetModel
  let user: Sweet.UserModel

  public init(tweet: Sweet.TweetModel, user: Sweet.UserModel) {
    self.tweet = tweet
    self.user = user
  }
}

public struct TweetStatusEntry: TimelineEntry {
  public var date: Date
  let state: TweetWidgetState

  public init(date: Date, state: TweetWidgetState) {
    self.date = date
    self.state = state
  }
}

public struct TweetStatusView: View {
  @Environment(\.widgetFamily) var widgetFamily

  let entry: TweetStatusEntry

  public init(entry: TweetStatusEntry) {
    self.entry = entry
  }

  public var body: some View {
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
      .padding(10)
      .widgetURL(
        URL(string: "penguin://")!.appending(queryItems: [
          .init(name: "tweetID", value: model.tweet.id)
        ]))
    }
  }
}

struct SmallTweetStatusView: View {
  let model: TweetWidgetModel

  var body: some View {
    VStack(alignment: .leading) {
      HStack {
        let imageData = try! Data(contentsOf: model.user.profileImageURL!)
        let image = ImageData(data: imageData)!

        Image(image: image)
          .resizable()
          .clipShape(Circle())
          .overlay {
            Circle().stroke(.secondary, lineWidth: 2)
          }
          .frame(width: 40, height: 40)

        VStack(alignment: .leading) {
          Text(model.user.name)
            .font(.caption2)
            .bold()
            .lineLimit(1)
          Text("@\(model.user.userName)")
            .font(.caption2)
            .foregroundColor(.secondary)
            .lineLimit(1)
        }
      }

      Text(model.tweet.tweetText)
        .font(.caption2)
    }
  }
}

struct MediumTweetStatusView: View {
  let model: TweetWidgetModel

  var body: some View {
    HStack(alignment: .top) {
      let imageData = try! Data(contentsOf: model.user.profileImageURL!)
      let image = ImageData(data: imageData)!

      Image(image: image)
        .resizable()
        .clipShape(Circle())
        .overlay {
          Circle().stroke(.secondary, lineWidth: 2)
        }
        .frame(width: 50, height: 50)

      VStack(alignment: .leading) {
        HStack {
          (Text(model.user.name).bold()
            + Text("@\(model.user.userName)").foregroundColor(.secondary))
            .lineLimit(1)
            .font(.caption2)

          Spacer()
          Text(model.tweet.createdAt!.formatted(.relative(presentation: .named)))
        }

        Text(model.tweet.tweetText)
          .font(.caption2)
      }
    }
  }
}

struct LargeTweetStatusView: View {
  let model: TweetWidgetModel

  var body: some View {
    MediumTweetStatusView(model: model)
  }
}

struct ExtraLargeTweetStatusView: View {
  let model: TweetWidgetModel

  var body: some View {
    LargeTweetStatusView(model: model)
  }
}

struct TweetStatusView_Previews: PreviewProvider {
  static var previews: some View {
    TweetStatusView(entry: .init(date: .now, state: .loggedIn(model: .init(tweet: .init(id: "id", text: "text", createdAt: .now), user: .init(id: "id", name: "name", userName: "userName", profileImageURL: URL(string: "https://pbs.twimg.com/profile_images/974322170309390336/tY8HZIhk_400x400.jpg")!)))))
    .previewContext(WidgetPreviewContext(family: .systemLarge))
  }
}

struct RectangularTweetStatusView: View {
  let model: TweetWidgetModel

  var body: some View {
    Text(model.tweet.tweetText)
  }
}

struct AccessoryInlineTweetStatusView: View {
  let model: TweetWidgetModel

  var body: some View {
    Text(model.tweet.tweetText)
  }
}
