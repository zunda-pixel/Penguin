//
//  QueryBuilder.swift
//

import Foundation

struct QueryBuilder {
  var tweetType: TweetType = .all
  var excludeRetweet = false
  var onlyVerified = false
  var hasLink = false
  var hasHashTag = false
  var hasMentions = false
  var hasVideo = false
  var hasMedia = false
  var hashImage = false
  var from = ""
  var to = ""
  var url = ""
  var retweetsOf = ""

  var query: String { queries.joined(separator: " ") }

  @ArrayBuilder<String>
  var queries: [String] {
    tweetType.query

    if excludeRetweet { "-is:retweet" }

    if onlyVerified { "is:verified" }

    if hasHashTag { "has:hashtags" }

    if hasLink { "has:links" }

    if hasMentions { "has:mentions" }

    if hasMedia { "has:media" }

    if hashImage { "has:images" }

    if hasVideo { "has:video_link" }

    if !from.isEmpty { "from:\(from)" }

    if !to.isEmpty { "to:\(to)" }

    if !url.isEmpty { "url:\"\(url)\"" }

    if !retweetsOf.isEmpty { "retweets_of:\(retweetsOf)" }
  }
}
