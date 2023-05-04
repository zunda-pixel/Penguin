//
//  FollowingUserViewModel.swift
//

import Foundation
import Sweet

@MainActor final class FollowingUserViewModel: UsersViewProtocol, Hashable {
  let userID: String
  let ownerID: String

  var paginationToken: String?

  @Published var errorHandle: ErrorHandle?
  @Published var users: [Sweet.UserModel]

  init(userID: String, ownerID: String) {
    self.userID = userID
    self.ownerID = ownerID
    self.users = []
  }

  nonisolated static func == (lhs: FollowingUserViewModel, rhs: FollowingUserViewModel) -> Bool {
    lhs.userID == rhs.userID && lhs.ownerID == rhs.ownerID
  }

  nonisolated func hash(into hasher: inout Hasher) {
    hasher.combine(userID)
    hasher.combine(ownerID)
  }

  func fetchUsers(reset resetData: Bool) async {
    do {
      let response = try await Sweet(userID: userID).followingUsers(
        userID: ownerID,
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
