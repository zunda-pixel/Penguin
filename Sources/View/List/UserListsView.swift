//
// UserListViewModel.swift
//

import Sweet
import SwiftUI

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

struct UserListsView: View {
  enum ListTab: String, CaseIterable, Identifiable {
    case owned = "List"
    case added = "Added List"

    var id: String { rawValue }
  }

  @State var selection: ListTab = .owned

  @ObservedObject var viewModel: UserListViewModel

  var body: some View {
    TabView(selection: $selection) {
      List(viewModel.ownedLists) { list in
        let owner = viewModel.getListOwner(list: list)
        ListCellView(list: list, owner: owner, userID: viewModel.userID)
          .task {
            if list.id == viewModel.ownedLists.last?.id {
              await viewModel.fetchOwnedLists()
            }
          }
      }
      .overlay(alignment: .center) {
        if viewModel.ownedLists.isEmpty {
          Text("Not Found List")
        }
      }
      .tag(ListTab.owned)
      List(viewModel.addedLists) { list in
        let owner = viewModel.getListOwner(list: list)
        ListCellView(list: list, owner: owner, userID: viewModel.userID)
          .task {
            if list.id == viewModel.addedLists.last?.id {
              await viewModel.fetchAddedLists()
            }
          }
      }
      .overlay(alignment: .center) {
        if viewModel.addedLists.isEmpty {
          Text("Not Found List")
        }
      }
      .tag(ListTab.added)
    }
    .tabViewStyle(.page)
    .toolbar {
      ToolbarItem(placement: .navigation) {
        Picker("Tab", selection: $selection) {
          ForEach(ListTab.allCases) { tab in
            Text(tab.rawValue).tag(tab)
          }
        }
        .pickerStyle(.segmented)
      }
    }
    .task {
      await viewModel.fetchList()
    }
  }
}
