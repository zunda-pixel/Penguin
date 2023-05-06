//
//  UsersView.swift
//

import Sweet
import SwiftUI

struct UsersView<ViewModel: UsersViewProtocol>: View {
  @StateObject var viewModel: ViewModel
  @State var loadingUsers = false
  @State var selectedUserIDs: Set<String> = []
  @Environment(\.editMode) var editMode

  var isEditing: Bool {
    editMode?.wrappedValue == .active
  }

  func fetchUsers(reset: Bool) async {
    guard !loadingUsers else { return }

    loadingUsers.toggle()
    defer { loadingUsers.toggle() }

    await viewModel.fetchUsers(reset: reset)
  }

  var body: some View {
    List(selection: $selectedUserIDs) {
      if viewModel.users.isEmpty && loadingUsers {
        ForEach(0..<100) { _ in
          UserCellView(ownerID: "", user: .placeHolder)
        }
        .redacted(reason: .placeholder)
      } else {
        if editMode?.wrappedValue.isEditing == true && !viewModel.users.isEmpty {
          Section {
            if selectedUserIDs.count != viewModel.users.count {
              Button("Select All") {
                selectedUserIDs = Set(viewModel.users.map(\.id))
              }
            }

            if !selectedUserIDs.isEmpty {
              Button("DeSelect All") {
                selectedUserIDs = Set()
              }

              Button("Delete Selected User", role: .destructive) {
                Task {
                  await viewModel.deleteUsers(ids: selectedUserIDs)
                }
              }
            }
          }
          .buttonStyle(.borderless)
        }

        ForEach(viewModel.users) { user in
          UserCellView(ownerID: viewModel.userID, user: user)
            .id(user.id)
            .task {
              if viewModel.users.last?.id == user.id {
                await viewModel.fetchUsers(reset: false)
              }
            }
        }
        .if(viewModel.enableDelete) {
          $0.onDelete { index in
            Task {
              let users = index.map { viewModel.users[$0] }
              await viewModel.deleteUsers(ids: users.map(\.id))
            }
          }
        }
      }
    }
    .toolbar {
      if viewModel.enableDelete {
        EditButton()
      }
    }
    .alert(errorHandle: $viewModel.errorHandle)
    .refreshable {
      await fetchUsers(reset: true)
    }
    .task {
      await fetchUsers(reset: false)
    }
  }
}
