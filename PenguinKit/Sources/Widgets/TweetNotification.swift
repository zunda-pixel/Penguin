//
//  TweetNotification.swift
//

#if canImport(ActivityKit)
  import SwiftUI
  import WidgetKit

  struct TweetNotification: View {
    let attributes: TweetAttributes

    var body: some View {
      HStack {
        Image(systemName: "person")
          .font(.system(size: 30))

        VStack(alignment: .leading) {
          HStack {
            (Text(attributes.user.name).bold()
              + Text(" @\(attributes.user.userName)").foregroundColor(.secondary))

            Spacer()

            Text(attributes.tweet.createdAt!.formatted(.relative(presentation: .named)))
              .foregroundColor(.secondary)
          }

          Text(attributes.tweet.tweetText)
            .fixedSize(horizontal: false, vertical: true)
            .lineLimit(2)
        }
      }
    }
  }

  struct TweetNotification_Previews: PreviewProvider {
    static var previews: some View {
      TweetNotification(
        attributes: .init(
          user: .init(
            id: "", name: "zunda", userName: "zunda",
            profileImageURL: URL(
              string:
                "https://pbs.twimg.com/profile_images/1488548719062654976/u6qfBBkF_400x400.jpg")!
          ),
          tweet: .init(id: "", text: "zunda", createdAt: Date())
        )
      )
      .previewContext(WidgetPreviewContext(family: .systemMedium))
    }
  }

#endif
