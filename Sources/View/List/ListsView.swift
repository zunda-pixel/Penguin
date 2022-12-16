//
//  ListsView.swift
//

import OrderedCollections
import Sweet
import SwiftUI
import os

struct ListsView: View {
  @StateObject var router = NavigationPathRouter()

  let userID: String

  @State var allLists: [Sweet.ListModel] = []

  @State var pinnedListIDs: OrderedSet<String> = []
  var pinnedLists: [Sweet.ListModel] {
    pinnedListIDs.compactMap { id in allLists.first(where: { id == $0.id }) }
  }

  @State var ownedListIDs: OrderedSet<String> = []
  var ownedLists: [Sweet.ListModel] {
    ownedListIDs.map { id in allLists.first(where: { id == $0.id })! }
  }

  @State var followingListIDs: OrderedSet<String> = []
  var followingLists: [Sweet.ListModel] {
    followingListIDs.map { id in allLists.first(where: { id == $0.id })! }
  }

  @State var errorHandle: ErrorHandle?

  @State var isPresentedAddList = false

  @State var owners: [Sweet.UserModel] = []

  @State var ownedPaginationToken: String? = nil
  @State var followingPaginationToken: String? = nil

  @Binding var loginUsers: [Sweet.UserModel]
  @Binding var currentUser: Sweet.UserModel?
  @Binding var settings: Settings
  
  func fetchFollowingLists() async {
    do {
      let response = try await Sweet(userID: userID)
        .listsFollowed(by: userID, paginationToken: followingPaginationToken)

      followingPaginationToken = response.meta.nextToken

      allLists.append(contentsOf: response.lists)
      owners.append(contentsOf: response.users)

      self.followingListIDs = OrderedSet(response.lists.map(\.id))
    } catch {
      errorHandle = ErrorHandle(error: error)
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
      errorHandle = ErrorHandle(error: error)
    }
  }

  func fetchPinnedLists() async {
    do {
      let response = try await Sweet(userID: userID).pinnedLists(by: userID)

      pinnedListIDs = OrderedSet(response.lists.map(\.id))
    } catch {
      errorHandle = ErrorHandle(error: error)
    }
  }

  func deleteOwnedList(offsets: IndexSet) async {
    let list = ownedLists[offsets.first!]

    do {
      try await Sweet(userID: userID).deleteList(listID: list.id)
      ownedListIDs.remove(list.id)
    } catch {
      errorHandle = ErrorHandle(error: error)
    }
  }

  func unFollowList(offsets: IndexSet) async {
    let list = followingLists[offsets.first!]

    do {
      try await Sweet(userID: userID).unFollowList(userID: userID, listID: list.id)

      followingListIDs.remove(list.id)
    } catch {
      errorHandle = ErrorHandle(error: error)
    }
  }

  func unPinList(offsets: IndexSet) async {
    let list = followingLists[offsets.first!]

    do {
      try await Sweet(userID: userID).unPinList(userID: userID, listID: list.id)

      pinnedListIDs.remove(list.id)
    } catch {
      errorHandle = ErrorHandle(error: error)
    }
  }
  
  @ViewBuilder
  func listCellView(list: Sweet.ListModel) -> some View {
    let owner = owners.first { $0.id == list.ownerID }!
    let isPinned = pinnedListIDs.contains(list.id)
    PinnableListCellView(
      list: list,
      owner: owner,
      userID: userID,
      delegate: self,
      isPinned: isPinned
    )
  }

  var body: some View {
    NavigationStack(path: $router.path) {
      List {
        Group {
          Section("PINNED LISTS") {
            if pinnedListIDs.count == 0 {
              Text("No lists found")
                .foregroundColor(.secondary)
            }
            
            ForEach(pinnedLists) { list in
              listCellView(list: list)
                .task {
                  if list.id == pinnedLists.last?.id && pinnedLists.count > 50 {
                    await fetchPinnedLists()
                  }
                }
            }
            .onDelete { offsets in
              Task {
                await unPinList(offsets: offsets)
              }
            }
          }
          
          Section("OWNED LISTS") {
            if ownedLists.count == 0 {
              Text("No lists found")
                .foregroundColor(.secondary)
            }
            
            ForEach(ownedLists) { list in
              listCellView(list: list)
                .task {
                  if list.id == ownedLists.last?.id && ownedLists.count > 50 {
                    await fetchOwnedLists()
                  }
                }
            }
            .onDelete { offsets in
              Task {
                await deleteOwnedList(offsets: offsets)
              }
            }
          }
          
          Section("FOLLOWING LISTS") {
            if followingLists.count == 0 {
              Text("No lists found")
                .foregroundColor(.secondary)
            }
            
            ForEach(followingLists) { list in
              listCellView(list: list)
                .task {
                  if list.id == followingLists.last?.id && followingLists.count > 50 {
                    await fetchFollowingLists()
                  }
                }
            }
            .onDelete { offsets in
              Task {
                await unFollowList(offsets: offsets)
              }
            }
          }
        }
        .listContentAttribute()
      }
      .navigationBarAttribute()
      .scrollViewAttitude()
      .navigationTitle("List")
      .navigationBarTitleDisplayMode(.large)
      .navigationDestination()
      .toolbar {
        if let currentUser {
          ToolbarItem(placement: .navigationBarLeading) {
            LoginMenu(bindingCurrentUser: $currentUser, loginUsers: $loginUsers, settings: $settings, currentUser: currentUser)
          }
        }
        
        ToolbarItem(placement: .navigationBarTrailing) {
          Button {
            isPresentedAddList.toggle()
          } label: {
            Image(systemName: "plus.app")
          }
        }
      }
      .sheet(isPresented: $isPresentedAddList) {
        NewListView(userID: userID, delegate: self)
      }
    }
    .environmentObject(router)
    .alert(errorHandle: $errorHandle)
    .task {
      guard allLists.isEmpty else { return }

      await withTaskGroup(of: Void.self) { group in
        group.addTask { await fetchOwnedLists() }
        group.addTask { await fetchFollowingLists() }
        group.addTask { await fetchPinnedLists() }
      }
    }
  }
}

extension ListsView: NewListDelegate {
  func didCreateList(list: Sweet.ListModel) {
    allLists.append(list)
    ownedListIDs.append(list.id)
  }
}

extension ListsView: PinnableListCellDelegate {
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

      errorHandle = ErrorHandle(error: error)
    }
  }
}
