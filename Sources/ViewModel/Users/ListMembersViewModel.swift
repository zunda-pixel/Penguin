//
//  ListMembersViewModel.swift
//

import Foundation
import Sweet

@MainActor final class ListMembersViewModel: UsersViewProtocol, Hashable {
  let userID: String
  let listID: String

  var paginationToken: String?
  var loadingUser: Bool

  @Published var errorHandle: ErrorHandle?
  @Published var users: [Sweet.UserModel]

  init(userID: String, listID: String) {
    self.userID = userID
    self.listID = listID
    
    self.loadingUser = false
    self.users = []
  }
  
  nonisolated static func == (lhs: ListMembersViewModel, rhs: ListMembersViewModel) -> Bool {
    lhs.listID == lhs.listID
  }

  nonisolated func hash(into hasher: inout Hasher) {
    hasher.combine(listID)
    hasher.combine(userID)
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
      let errorHandle = ErrorHandle(error: error)
      errorHandle.log()
      self.errorHandle = errorHandle
    }
  }
}
