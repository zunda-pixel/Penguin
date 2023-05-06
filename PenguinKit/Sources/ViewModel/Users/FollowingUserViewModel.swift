//
//  FollowingUserViewModel.swift
//

import Foundation
import Sweet

@MainActor final class FollowingUserViewModel: UsersViewProtocol, Hashable {
  let userID: String
  let ownerID: String
  var enableDelete: Bool {
    userID == ownerID
  }

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

  func deleteUsers(ids: some Sequence<String>) async {
    let willDeleteUsers = users.filter { ids.contains($0.id) }
    users.removeAll { ids.contains($0.id) }
    var deletedIDs: [String] = []

    do {
      try await withThrowingTaskGroup(of: String.self) { group in
        for id in ids {
          group.addTask {
            try await Sweet(userID: self.userID).unFollow(from: self.userID, to: id)
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
