//
//  ListsView.swift
//

import Sweet
import SwiftUI

struct ListsView<ViewModel: ListsViewModelProtocol>: View {
  @StateObject var router = NavigationPathRouter()

  @StateObject var viewModel: ViewModel

  let id = UUID()

  @Binding var loginUsers: [Sweet.UserModel]
  @Binding var currentUser: Sweet.UserModel?
  @Binding var settings: Settings

  var body: some View {
    NavigationStack(path: $router.path) {
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
      .navigationBarAttribute()
      .scrollViewAttitude()
      .navigationTitle("List")
      .navigationBarTitleDisplayModeIfAvailable(.large)
      .navigationDestination()
      .toolbar {
        if let currentUser {
          #if os(macOS)
            let placement: ToolbarItemPlacement = .navigation
          #else
            let placement: ToolbarItemPlacement = .navigationBarLeading
          #endif

          ToolbarItem(placement: placement) {
            LoginMenu(
              bindingCurrentUser: $currentUser, loginUsers: $loginUsers, settings: $settings,
              currentUser: currentUser)
          }
        }

        #if os(macOS)
          let placement: ToolbarItemPlacement = .navigation
        #else
          let placement: ToolbarItemPlacement = .navigationBarTrailing
        #endif

        ToolbarItem(placement: placement) {
          Button {
            viewModel.isPresentedAddList.toggle()
          } label: {
            Image(systemName: "plus.app")
          }
        }
      }
      .sheet(isPresented: $viewModel.isPresentedAddList) {
        NewListView(viewModel: NewListViewModel(userID: viewModel.userID, delegate: viewModel))
      }
    }
    .environmentObject(router)
    .alert(errorHandle: $viewModel.errorHandle)
    .task {
      await viewModel.onAppear()
    }
  }
}
