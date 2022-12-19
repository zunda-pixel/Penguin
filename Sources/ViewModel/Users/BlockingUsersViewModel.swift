//
//  FollowingUserViewModel.swift
//

import Foundation
import Sweet

@MainActor final class BlockingUsersViewModel: UsersViewProtocol, Hashable {
  let userID: String
  let ownerID: String

  var paginationToken: String?
  var loadingUser: Bool

  @Published var errorHandle: ErrorHandle?
  @Published var users: [Sweet.UserModel]

  init(userID: String, ownerID: String) {
    self.userID = userID
    self.ownerID = ownerID
    
    self.loadingUser = false
    self.users = []
  }

  nonisolated static func == (lhs: BlockingUsersViewModel, rhs: BlockingUsersViewModel) -> Bool {
    lhs.userID == lhs.userID && lhs.ownerID == rhs.ownerID
  }

  nonisolated func hash(into hasher: inout Hasher) {
    hasher.combine(userID)
    hasher.combine(ownerID)
  }
  
  func fetchUsers(reset resetData: Bool) async {
    guard !loadingUser else { return }

    loadingUser.toggle()
    defer { loadingUser.toggle() }

    do {
      let response = try await Sweet(userID: userID).blockingUsers(
        userID: userID,
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
      errorHandle = ErrorHandle(error: error)
    }
  }
}
