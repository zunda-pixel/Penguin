//
// UserListViewModel.swift
//

import Sweet
import SwiftUI

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
    #if !os(macOS)
    .tabViewStyle(.page)
    #endif
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
