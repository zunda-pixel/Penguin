//
//  UserListViewModel.swift
//

import Foundation
import Sweet

@MainActor class UserListViewModel: ObservableObject, Hashable {
  // TODO何度も同じリクエストが送られてしまっている
  
  nonisolated static func == (lhs: UserListViewModel, rhs: UserListViewModel) -> Bool {
    return lhs.userID == rhs.userID && lhs.ownerID == rhs.ownerID
  }
  
  nonisolated func hash(into hasher: inout Hasher) {
    hasher.combine(userID)
    hasher.combine(ownerID)
  }
  
  let userID: String
  let ownerID: String
  
  init(userID: String, ownerID: String) {
    self.userID = userID
    self.ownerID = ownerID
  }
  
  var allLists: [Sweet.ListModel] = []
  var allUsers: [Sweet.UserModel] = []
  
  @Published var ownedListIDs: Set<String> = []
  @Published var addedListIDs: Set<String> = []
  
  var ownedLists: [Sweet.ListModel] { ownedListIDs.map { id in allLists.first { $0.id == id }! } }
  var addedLists: [Sweet.ListModel] { addedListIDs.map { id in allLists.first { $0.id == id }! } }

  var ownedPaginationToken: String? = nil
  var addedPaginationToken: String? = nil

  @Published var errorHandle: ErrorHandle?

  func fetchList() async {
    await withTaskGroup(of: Void.self) { group in
      group.addTask {
        await self.fetchAddedLists()
      }
      
      group.addTask {
        await self.fetchOwnedLists()
      }
    }
  }
  
  func fetchAddedLists() async {
    do {
      let addedResponse = try await Sweet(userID: userID).addedLists(
        userID: ownerID,
        paginationToken: addedPaginationToken
      )

      addedPaginationToken = addedResponse.meta.nextToken

      self.allLists.append(contentsOf: addedResponse.lists)
      self.allUsers.append(contentsOf: addedResponse.users)

      self.addedListIDs.formUnion(Set(addedResponse.lists.map(\.id)))
    } catch {
      errorHandle = ErrorHandle(error: error)
    }
  }

  func fetchOwnedLists() async {
    do {
      let ownedResponse = try await Sweet(userID: userID).ownedLists(
        userID: ownerID,
        paginationToken: ownedPaginationToken
      )

      ownedPaginationToken = ownedResponse.meta.nextToken

      self.allLists.append(contentsOf: ownedResponse.lists)
      self.allUsers.append(contentsOf: ownedResponse.users)

      self.ownedListIDs.formUnion(ownedResponse.lists.map(\.id))
    } catch {
      errorHandle = ErrorHandle(error: error)
    }
  }

  func getListOwner(list: Sweet.ListModel) -> Sweet.UserModel {
    return allUsers.first { $0.id == list.ownerID! }!
  }
}
