//
//  SpaceDetailViewModel.swift
//

import Foundation
import Sweet

@MainActor final class SpaceDetailViewModel: ObservableObject, Hashable {
  nonisolated static func == (lhs: SpaceDetailViewModel, rhs: SpaceDetailViewModel) -> Bool {
    lhs.userID == rhs.userID && lhs.space == rhs.space && lhs.creator == rhs.creator
      && lhs.speakers == rhs.speakers
  }

  nonisolated func hash(into hasher: inout Hasher) {
    hasher.combine(userID)
    hasher.combine(space)
    hasher.combine(creator)
    hasher.combine(speakers)
  }

  let userID: String
  let space: Sweet.SpaceModel
  let creator: Sweet.UserModel
  let speakers: [Sweet.UserModel]

  init(
    userID: String,
    space: Sweet.SpaceModel,
    creator: Sweet.UserModel,
    speakers: [Sweet.UserModel]
  ) {
    self.userID = userID
    self.space = space
    self.creator = creator
    self.speakers = speakers
  }
}
