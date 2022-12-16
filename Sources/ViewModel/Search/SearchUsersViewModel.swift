//
//  SearchUsersViewModel.swift
//

import Foundation
import Sweet

@MainActor final class SearchUsersViewModel: UsersViewProtocol, Hashable {
  nonisolated static func == (lhs: SearchUsersViewModel, rhs: SearchUsersViewModel) -> Bool {
    lhs.userID == rhs.userID && lhs.query == rhs.query
  }

  nonisolated func hash(into hasher: inout Hasher) {
    hasher.combine(userID)
  }

  var paginationToken: String?
  let query: String
  @Published var errorHandle: ErrorHandle?

  var loadingUser: Bool = false

  let userID: String

  init(userID: String, query: String) {
    self.userID = userID
    self.query = query
  }

  @Published var users: [Sweet.UserModel] = []

  func fetchUsers(reset resetData: Bool) async {
    guard !loadingUser else { return }

    loadingUser.toggle()
    defer { loadingUser.toggle() }

    var newUsers: [Sweet.UserModel] = []

    if let response = try? await Sweet(userID: userID).user(screenID: query) {
      newUsers.append(response.user)
    }

    if let response = try? await Sweet(userID: userID).user(userID: query) {
      if !newUsers.contains(where: { $0.id == response.user.id }) {
        newUsers.append(response.user)
      }
    }

    self.users = newUsers
  }
}
