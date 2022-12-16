//
//  ListMembersViewModel.swift
//

import Foundation
import Sweet

@MainActor final class ListMembersViewModel: UsersViewProtocol, Hashable {
  nonisolated static func == (lhs: ListMembersViewModel, rhs: ListMembersViewModel) -> Bool {
    lhs.listID == lhs.listID
  }

  nonisolated func hash(into hasher: inout Hasher) {
    hasher.combine(listID)
    hasher.combine(userID)
  }

  let listID: String
  var paginationToken: String?
  @Published var errorHandle: ErrorHandle?

  @Published var users: [Sweet.UserModel] = []

  let userID: String

  var loadingUser: Bool = false

  init(userID: String, listID: String) {
    self.userID = userID
    self.listID = listID
  }

  func fetchUsers(reset resetData: Bool) async {
    guard !loadingUser else { return }

    loadingUser.toggle()
    defer { loadingUser.toggle() }

    do {
      let response = try await Sweet(userID: userID).listMembers(
        listID: listID,
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
