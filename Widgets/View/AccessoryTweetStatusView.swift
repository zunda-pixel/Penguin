//
//  AccessoryTweetStatusView.swift
//

import SwiftUI

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
