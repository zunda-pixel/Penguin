//
//  TweetModel+Extension.swift
//

import Foundation
import HTMLString
import Sweet

extension Sweet.TweetModel {
  static let placeHolder: Self = .init(
    id: "id",
    text: "This is Placeholder Text.\n This  tweets is loading...",
    createdAt: .now.addingTimeInterval(-1000),
    attachments: .init(pollID: "pollID")
  )

  public var tweetText: String {
    return self.text.removingHTMLEntities()
  }

  var isEdited: Bool {
    editHistoryTweetIDs.count >= 2
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

  func dictionaryValue() -> [String: Any] {
    let encoder = JSONEncoder.twitter

    let dictionary: [String: Any?] = [
      "id": id,
      "text": text,
      "authorID": authorID,
      "lang": lang,
      "createdAt": createdAt,
      "replySetting": replySetting?.rawValue,
      "conversationID": conversationID,
      "sensitive": sensitive,
      "replyUserID": replyUserID,
      "geo": try! encoder.encodeIfExists(geo),
      "entities": try! encoder.encodeIfExists(entity),
      "attachments": try! encoder.encodeIfExists(attachments),
      "contextAnnotations": try! encoder.encodeIfExists(contextAnnotations),
      "organicMetrics": try! encoder.encodeIfExists(organicMetrics),
      "privateMetrics": try! encoder.encodeIfExists(privateMetrics),
      "promotedMetrics": try! encoder.encodeIfExists(promotedMetrics),
      "publicMetrics": try! encoder.encodeIfExists(publicMetrics),
      "referencedTweets": try! encoder.encodeIfExists(referencedTweets),
      "withheld": try! encoder.encodeIfExists(withheld),
      "editControl": try! encoder.encodeIfExists(editControl),
      "editHistoryTweetIDs": try! encoder.encodeIfExists(editHistoryTweetIDs),
    ]

    return dictionary.compactMapValues { $0 }
  }
}
