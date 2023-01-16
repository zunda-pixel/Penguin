//
//  User+Extension.swift
//

import Foundation
import Sweet

extension User {
  func setUserModel(_ user: Sweet.UserModel) throws {
    self.id = user.id
    self.name = user.name
    self.userName = user.userName
    self.verified = user.verified ?? false
    self.profileImageURL = user.profileImageURL
    self.descriptions = user.description
    self.protected = user.protected ?? false
    self.url = user.url
    self.createdAt = user.createdAt
    self.location = user.location
    self.pinnedTweetID = user.pinnedTweetID

    let encoder = JSONEncoder.twitter
    self.metrics = try encoder.encodeIfExists(user.metrics)
    self.withheld = try encoder.encodeIfExists(user.withheld)
    self.entities = try encoder.encodeIfExists(user.entity)
  }
}
