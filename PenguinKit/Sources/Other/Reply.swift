//
//  Reply.swift
//

import Foundation
import Sweet

struct Reply: Identifiable {
  var id: String { replyID }
  let replyID: String
  let ownerID: String
  let replyUsers: [Sweet.UserModel]

  init(replyID: String, ownerID: String, replyUsers: [Sweet.UserModel]) {
    self.replyID = replyID
    self.ownerID = ownerID
    // ownerが先頭に来るようにする
    self.replyUsers = replyUsers.sorted { user1, user2 in
      user1.id == ownerID && user2.id != ownerID
    }
  }
}
