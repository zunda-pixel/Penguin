//
//  TweetModel+Extension.swift
//

import Foundation
import Sweet
import HTMLString

extension Sweet.TweetModel {
  public var tweetText: String {
    let tweetText = removeTwitterURL(from: self.text)
    return tweetText.removingHTMLEntities()
  }

  var isEdited: Bool {
    editHistoryTweetIDs.count >= 2
  }

  func removeTwitterURL(from tweet: String) -> String {
    var tweetText = tweet

    let twitterURLRegex: String = "https://twitter.com"

    let urls = self.entity?.urls ?? []

    for url in urls {
      let urlString = "\(url.url)"
      
      if tweetText.contains(urlString) {
        if (url.expandedURL ?? urlString).contains(twitterURLRegex) {
          tweetText = tweetText.replacingOccurrences(of: urlString, with: "")
        }
      }
    }

    return tweetText
  }

  enum ReferencedType {
    case normal
    case quote
    case replyAndQuote
    case retweet
    case reply
  }

  var referencedType: ReferencedType {
    if referencedTweets.isEmpty {
      return .normal
    }

    if referencedTweets.contains(where: { $0.type == .repliedTo }) {
      if referencedTweets.contains(where: { $0.type == .quoted }) {
        return .replyAndQuote
      } else {
        return .reply
      }
    }

    if referencedTweets.contains(where: { $0.type == .quoted }) {
      return .quote
    }

    if referencedTweets.contains(where: { $0.type == .retweeted }) {
      return .retweet
    }

    fatalError()
  }
}
