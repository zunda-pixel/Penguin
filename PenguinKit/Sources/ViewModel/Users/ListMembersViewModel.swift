//
//  ListMembersViewModel.swift
//

import Foundation
import Sweet

@MainActor final class ListMembersViewModel: UsersViewProtocol, Hashable {
  let userID: String
  let listID: String
  let enableDelete: Bool = true

  var paginationToken: String?

  @Published var errorHandle: ErrorHandle?
  @Published var users: [Sweet.UserModel]

  init(userID: String, listID: String) {
    self.userID = userID
    self.listID = listID
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

  func deleteUsers(ids: some Sequence<String>) async {
    let willDeleteUsers = users.filter { ids.contains($0.id) }
    users.removeAll { ids.contains($0.id) }
    var deletedIDs: [String] = []

    do {
      try await withThrowingTaskGroup(of: String.self) { group in
        for id in ids {
          group.addTask {
            try await Sweet(userID: self.userID).deleteListMember(
              listID: self.listID, userID: self.userID)
            return id
          }
        }

        for try await id in group {
          deletedIDs.append(id)
        }
      }
    } catch {
      let errorHandle = ErrorHandle(error: error)
      errorHandle.log()
      self.errorHandle = errorHandle
    }

    let notDeletedUser = willDeleteUsers.filter { !deletedIDs.contains($0.id) }
    users.append(contentsOf: notDeletedUser)
  }
}
