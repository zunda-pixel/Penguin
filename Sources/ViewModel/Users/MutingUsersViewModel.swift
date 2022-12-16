//
//  MutingUsersViewModel.swift
//

import Foundation
import Sweet

@MainActor final class MutingUsersViewModel: UsersViewProtocol, Hashable {
  nonisolated static func == (lhs: MutingUsersViewModel, rhs: MutingUsersViewModel) -> Bool {
    lhs.userID == lhs.userID && lhs.ownerID == rhs.ownerID
  }

  nonisolated func hash(into hasher: inout Hasher) {
    hasher.combine(userID)
    hasher.combine(ownerID)
  }

  var paginationToken: String?
  @Published var errorHandle: ErrorHandle?

  @Published var users: [Sweet.UserModel] = []

  var loadingUser: Bool = false

  let userID: String

  let ownerID: String

  init(userID: String, ownerID: String) {
    self.userID = userID
    self.ownerID = ownerID
  }

  func fetchUsers(reset resetData: Bool) async {
    guard !loadingUser else { return }

    loadingUser.toggle()
    defer { loadingUser.toggle() }

    do {
      let response = try await Sweet(userID: userID).mutingUsers(
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
