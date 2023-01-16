//
//  RetweetUsersViewModel.swift
//

import Foundation
import Sweet

@MainActor final class RetweetUsersViewModel: UsersViewProtocol, Hashable {
  let userID: String
  let tweetID: String

  var paginationToken: String?
  var loadingUser: Bool

  @Published var errorHandle: ErrorHandle?
  @Published var users: [Sweet.UserModel]

  init(userID: String, tweetID: String) {
    self.userID = userID
    self.tweetID = tweetID

    self.loadingUser = false
    self.users = []
  }

  nonisolated static func == (lhs: RetweetUsersViewModel, rhs: RetweetUsersViewModel) -> Bool {
    lhs.userID == lhs.userID && lhs.tweetID == rhs.tweetID
  }

  nonisolated func hash(into hasher: inout Hasher) {
    hasher.combine(userID)
  }

  func fetchUsers(reset resetData: Bool) async {
    guard !loadingUser else { return }

    loadingUser.toggle()
    defer { loadingUser.toggle() }

    do {
      let response = try await Sweet(userID: userID).retweetUsers(
        tweetID: tweetID,
        paginationToken: paginationToken
      )

      if resetData {
        users = []
      }

      response.users.forEach { newUser in
        if let firstIndex = users.firstIndex(where: { $0.id == newUser.id }) {
          users[firstIndex] = newUser
        } else {
          users.append(newUser)
        }
      }

      paginationToken = response.meta?.nextToken
    } catch {
      let errorHandle = ErrorHandle(error: error)
      errorHandle.log()
      self.errorHandle = errorHandle
    }
  }
}
