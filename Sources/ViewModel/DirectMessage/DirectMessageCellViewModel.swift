//
//  DirectMessageCellViewModel.swift
//

import Foundation
import Sweet

class DirectMessageCellViewModel: ObservableObject {
  let userID: String

  let directMessage: Sweet.DirectMessageModel
  let user: Sweet.UserModel
  let medias: [Sweet.MediaModel]

  let isBeforeElementSame: Bool

  init(
    userID: String,
    directMessage: Sweet.DirectMessageModel,
    user: Sweet.UserModel,
    medias: [Sweet.MediaModel],
    isBeforeElementSame: Bool
  ) {
    self.userID = userID
    self.directMessage = directMessage
    self.user = user
    self.medias = medias
    self.isBeforeElementSame = isBeforeElementSame
  }
}
