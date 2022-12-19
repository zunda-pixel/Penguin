//
//  TweetType.swift
//

import Foundation

enum TweetType: String, CaseIterable, Identifiable {
  case retweet = "Retweet"
  case reply = "Reply"
  case quote = "Quote"
  case all = "All"

  var id: String { rawValue }

  var query: String {
    switch self {
    case .all: return ""
    case .reply: return "is:reply"
    case .retweet: return "is:retweet"
    case .quote: return "is:quote"
    }
  }
}
