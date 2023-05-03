//
//  Reply.swift
//

import Foundation
import Sweet

struct Reply: Identifiable {
  let id: UUID
  let tweetContent: TweetContentModel
  let replyUsers: [Sweet.UserModel]

  init(tweetContent: TweetContentModel, replyUsers: [Sweet.UserModel]) {
    self.id = UUID()
    
    self.tweetContent = tweetContent
    // ownerが先頭に来るようにする
    self.replyUsers = replyUsers.sorted { user1, user2 in
      user1.id == tweetContent.author.id && user2.id != tweetContent.author.id
    }
  }
}
