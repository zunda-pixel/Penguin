//
//  TweetAttributes.swift
//

#if canImport(ActivityKit)
import ActivityKit
import Sweet

struct TweetAttributes: ActivityAttributes {
  let user: Sweet.UserModel
  let tweet: Sweet.TweetModel

  struct ContentState: Codable, Hashable {
  }
}
#endif
