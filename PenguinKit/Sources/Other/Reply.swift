//
//  Reply.swift
//

import Foundation

struct Reply: Identifiable {
  var id: String { replyID }
  let replyID: String
  let ownerID: String
  let replyUsers: [Sweet.UserModel]
}
