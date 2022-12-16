//
//  TweetAttributes.swift
//

import ActivityKit
import Sweet
import SwiftUI

struct TweetAttributes: ActivityAttributes {
  let user: Sweet.UserModel
  let tweet: Sweet.TweetModel

  public struct ContentState: Codable, Hashable {
  }
}
