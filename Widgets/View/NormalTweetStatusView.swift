//
//  NormalTweetStatusView.swift
//

import SwiftUI
import WidgetKit

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
        user: .init(id: "", name: "zunda", userName: "zunda", profileImageURL: URL(string: "https://pbs.twimg.com/profile_images/1488548719062654976/u6qfBBkF_400x400.jpg")!)
      )
    )
    .previewContext(WidgetPreviewContext(family: .systemExtraLarge))
  }
}
