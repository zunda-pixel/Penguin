//
//  SearchUsersViewModel.swift
//

import Foundation
import Sweet

@MainActor final class SearchUsersViewModel: UsersViewProtocol, Hashable {
  let userID: String
  let query: String

  var paginationToken: String?

  @Published var errorHandle: ErrorHandle?
  @Published var users: [Sweet.UserModel]

  init(userID: String, query: String) {
    self.userID = userID
    self.query = query
    self.users = []
  }

  nonisolated static func == (lhs: SearchUsersViewModel, rhs: SearchUsersViewModel) -> Bool {
    lhs.userID == rhs.userID && lhs.query == rhs.query
  }

  nonisolated func hash(into hasher: inout Hasher) {
    hasher.combine(userID)
  }

  func fetchUsers(reset resetData: Bool) async {
    var newUsers: [Sweet.UserModel] = []

    let removedWhiteSpaceQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)

    if removedWhiteSpaceQuery.isEmpty {
      return
    }

    if let response = try? await Sweet(userID: userID).user(screenID: removedWhiteSpaceQuery) {
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
