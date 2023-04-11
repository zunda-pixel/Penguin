//
//  ListsView.swift
//

import Sweet
import SwiftUI

struct ListsView<ViewModel: ListsViewModelProtocol>: View {
  @StateObject var viewModel: ViewModel
  @Binding var isPresentedAddList: Bool

  var body: some View {
    List {
      Group {
        Section("PINNED LISTS") {
          if viewModel.pinnedListIDs.count == 0 {
            Text("No lists found")
              .foregroundColor(.secondary)
          }

          ForEach(viewModel.pinnedLists) { list in
            PinnableListCellView(viewModel: viewModel.listCellView(list: list))
              .task {
                if list.id == viewModel.pinnedLists.last?.id && viewModel.pinnedLists.count > 50 {
                  await viewModel.fetchPinnedLists()
                }
              }
          }
          .onDelete { offsets in
            Task {
              await viewModel.unPinList(offsets: offsets)
            }
          }
        }

        Section("OWNED LISTS") {
          if viewModel.ownedLists.count == 0 {
            Text("No lists found")
              .foregroundColor(.secondary)
          }

          ForEach(viewModel.ownedLists) { list in
            PinnableListCellView(viewModel: viewModel.listCellView(list: list))
              .task {
                if list.id == viewModel.ownedLists.last?.id && viewModel.ownedLists.count > 50 {
                  await viewModel.fetchOwnedLists()
                }
              }
          }
          .onDelete { offsets in
            Task {
              await viewModel.deleteOwnedList(offsets: offsets)
            }
          }
        }

        Section("FOLLOWING LISTS") {
          if viewModel.followingLists.count == 0 {
            Text("No lists found")
              .foregroundColor(.secondary)
          }

          ForEach(viewModel.followingLists) { list in
            PinnableListCellView(viewModel: viewModel.listCellView(list: list))
              .task {
                if list.id == viewModel.followingLists.last?.id
                  && viewModel.followingLists.count > 50
                {
                  await viewModel.fetchFollowingLists()
                }
              }
          }
          .onDelete { offsets in
            Task {
              await viewModel.unFollowList(offsets: offsets)
            }
          }
        }
      }
      .listContentAttribute()
    }
    .alert(errorHandle: $viewModel.errorHandle)
    .task {
      await viewModel.onAppear()
    }
    .scrollViewAttitude()
    .sheet(isPresented: $isPresentedAddList) {
      let viewModel = NewListViewModel(userID: viewModel.userID, delegate: viewModel)
      NewListView(viewModel: viewModel)
    }
  }
}
