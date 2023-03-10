//
//  UserModel+Extension.swift
//

import Foundation
import Sweet

extension Sweet.UserModel {
  init(user: User) {
    let decoder = JSONDecoder.twitter

    let metrics = try! decoder.decodeIfExists(Sweet.UserPublicMetrics.self, from: user.metrics)
    let withheld = try! decoder.decodeIfExists(Sweet.WithheldModel.self, from: user.withheld)
    let entity = try! decoder.decodeIfExists(Sweet.UserEntityModel.self, from: user.entities)

    self.init(
      id: user.id!,
      name: user.name!,
      userName: user.userName!,
      verified: user.verified,
      profileImageURL: user.profileImageURL,
      description: user.descriptions,
      protected: user.protected,
      url: user.url,
      createdAt: user.createdAt,
      location: user.location,
      pinnedTweetID: user.pinnedTweetID,
      metrics: metrics,
      withheld: withheld,
      entity: entity
    )
  }
}
