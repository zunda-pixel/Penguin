//
//  ListsViewModel.swift
//

import Foundation
import OrderedCollections
import Sweet

@MainActor
protocol ListsViewModelProtocol: ObservableObject, NewListDelegate, PinnableListCellDelegate {
  var userID: String { get }

  var allLists: [Sweet.ListModel] { get set }

  var pinnedListIDs: OrderedSet<String> { get set }
  var pinnedLists: [Sweet.ListModel] { get }

  var ownedListIDs: OrderedSet<String> { get set }
  var ownedLists: [Sweet.ListModel] { get }

  var followingListIDs: OrderedSet<String> { get set }
  var followingLists: [Sweet.ListModel] { get }

  var errorHandle: ErrorHandle? { get set }

  var owners: [Sweet.UserModel] { get set }
  var ownedPaginationToken: String? { get set }
  var followingPaginationToken: String? { get set }

  func onAppear() async
  func fetchFollowingLists() async
  func fetchOwnedLists() async
  func fetchPinnedLists() async
  func deleteOwnedList(offsets: IndexSet) async
  func unFollowList(offsets: IndexSet) async
  func unPinList(offsets: IndexSet) async
  func listCellView(list: Sweet.ListModel) -> PinnableListCellViewModel
}

extension ListsViewModelProtocol {
  var pinnedLists: [Sweet.ListModel] {
    pinnedListIDs.compactMap { id in allLists.first(where: { id == $0.id }) }
  }
  var ownedLists: [Sweet.ListModel] {
    ownedListIDs.map { id in allLists.first(where: { id == $0.id })! }
  }
  var followingLists: [Sweet.ListModel] {
    followingListIDs.map { id in allLists.first(where: { id == $0.id })! }
  }
}

@MainActor final class ListsViewModel: ListsViewModelProtocol {
  let userID: String
  var allLists: [Sweet.ListModel]

  @Published var pinnedListIDs: OrderedSet<String>
  @Published var ownedListIDs: OrderedSet<String>
  @Published var followingListIDs: OrderedSet<String>

  init(userID: String) {
    self.userID = userID
    self.owners = []
    self.allLists = []
    self.pinnedListIDs = []
    self.ownedListIDs = []
    self.followingListIDs = []
  }

  @Published var errorHandle: ErrorHandle?

  var owners: [Sweet.UserModel]

  var ownedPaginationToken: String?
  var followingPaginationToken: String?

  func listCellView(list: Sweet.ListModel) -> PinnableListCellViewModel {
    let owner = owners.first { $0.id == list.ownerID }!
    let isPinned = pinnedListIDs.contains(list.id)
    return PinnableListCellViewModel(
      list: list,
      owner: owner,
      userID: userID,
      delegate: self,
      isPinned: isPinned
    )
  }

  func onAppear() async {
    await withTaskGroup(of: Void.self) { group in
      group.addTask { await self.fetchOwnedLists() }
      group.addTask { await self.fetchFollowingLists() }
      group.addTask { await self.fetchPinnedLists() }
    }
  }

  func fetchFollowingLists() async {
    do {
      let response = try await Sweet(userID: userID)
        .listsFollowed(by: userID, paginationToken: followingPaginationToken)

      followingPaginationToken = response.meta.nextToken

      allLists.append(contentsOf: response.lists)
      owners.append(contentsOf: response.users)

      self.followingListIDs = OrderedSet(response.lists.map(\.id))
    } catch {
      let errorHandle = ErrorHandle(error: error)
      errorHandle.log()
      self.errorHandle = errorHandle
    }
  }

  func fetchOwnedLists() async {
    do {
      let ownedResponse = try await Sweet(userID: userID)
        .ownedLists(userID: userID, paginationToken: ownedPaginationToken)
      ownedPaginationToken = ownedResponse.meta.nextToken

      allLists.append(contentsOf: ownedResponse.lists)

      owners.append(contentsOf: ownedResponse.users)

      self.ownedListIDs = OrderedSet(ownedResponse.lists.map(\.id))
    } catch {
      let errorHandle = ErrorHandle(error: error)
      errorHandle.log()
      self.errorHandle = errorHandle
    }
  }

  func fetchPinnedLists() async {
    do {
      let response = try await Sweet(userID: userID).pinnedLists(by: userID)

      pinnedListIDs = OrderedSet(response.lists.map(\.id))
    } catch {
      let errorHandle = ErrorHandle(error: error)
      errorHandle.log()
      self.errorHandle = errorHandle
    }
  }

  func deleteOwnedList(offsets: IndexSet) async {
    let list = ownedLists[offsets.first!]

    do {
      try await Sweet(userID: userID).deleteList(listID: list.id)
      ownedListIDs.remove(list.id)
    } catch {
      let errorHandle = ErrorHandle(error: error)
      errorHandle.log()
      self.errorHandle = errorHandle
    }
  }

  func unFollowList(offsets: IndexSet) async {
    let list = followingLists[offsets.first!]

    do {
      try await Sweet(userID: userID).unFollowList(userID: userID, listID: list.id)

      followingListIDs.remove(list.id)
    } catch {
      let errorHandle = ErrorHandle(error: error)
      errorHandle.log()
      self.errorHandle = errorHandle
    }
  }

  func unPinList(offsets: IndexSet) async {
    let list = followingLists[offsets.first!]

    do {
      try await Sweet(userID: userID).unPinList(userID: userID, listID: list.id)

      pinnedListIDs.remove(list.id)
    } catch {
      let errorHandle = ErrorHandle(error: error)
      errorHandle.log()
      self.errorHandle = errorHandle
    }
  }
}

extension ListsViewModel: NewListDelegate {
  func didCreateList(list: Sweet.ListModel) {
    allLists.append(list)
    ownedListIDs.append(list.id)
  }
}

extension ListsViewModel: PinnableListCellDelegate {
  func togglePin(listID: String) async {
    let isPinned = pinnedListIDs.contains(listID)

    do {
      if isPinned {
        pinnedListIDs.remove(listID)
        try await Sweet(userID: userID).unPinList(userID: userID, listID: listID)
      } else {
        pinnedListIDs.append(listID)
        try await Sweet(userID: userID).pinList(userID: userID, listID: listID)
      }
    } catch {
      if isPinned {
        pinnedListIDs.append(listID)
      } else {
        pinnedListIDs.remove(listID)
      }

      let errorHandle = ErrorHandle(error: error)
      errorHandle.log()
      self.errorHandle = errorHandle
    }
  }
}
