//
//  File.swift
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
        let uiImage = UIImage(data: imageData)

        Image(uiImage: uiImage!)
          .resizable()
          .clipShape(Circle())
          .overlay {
            Circle().stroke(.secondary, lineWidth: 2)
          }
          .frame(width: 50, height: 50)

        VStack(alignment: .leading) {
          Text(model.user.name)
            .bold()
            .lineLimit(1)
          Text("@\(model.user.userName)")
            .foregroundColor(.secondary)
            .lineLimit(1)
        }
      }

      Text(model.tweet.tweetText)
    }
  }
}

struct MediumTweetStatusView: View {
  let model: TweetWidgetModel

  var body: some View {
    HStack(alignment: .top) {
      let imageData = try! Data(contentsOf: model.user.profileImageURL!)
      let uiImage = UIImage(data: imageData)

      Image(uiImage: uiImage!)
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
          Spacer()
          Text(model.tweet.createdAt!.formatted(.relative(presentation: .named)))
        }

        Text(model.tweet.tweetText)
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

struct ExtraLargeTweetStatusView_Previews: PreviewProvider {
  static var previews: some View {
    ExtraLargeTweetStatusView(
      model: .init(
        tweet: .init(id: "", text: "zunda", createdAt: Date()),
        user: .init(
          id: "", name: "zunda", userName: "zunda",
          profileImageURL: URL(
            string: "https://pbs.twimg.com/profile_images/1488548719062654976/u6qfBBkF_400x400.jpg")!
        )
      )
    )
    .previewContext(WidgetPreviewContext(family: .systemExtraLarge))
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
