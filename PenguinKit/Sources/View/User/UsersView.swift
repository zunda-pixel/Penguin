//
//  UsersView.swift
//

import Sweet
import SwiftUI

struct UsersView<ViewModel: UsersViewProtocol>: View {
  @StateObject var viewModel: ViewModel
  @State var loadingUsers = false
  @State var selectedUserIDs: Set<String> = []
  #if !os(macOS)
    @Environment(\.editMode) var editMode

    var isEditing: Bool {
      editMode?.wrappedValue == .active
    }
  #endif

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
          UserCellView(viewModel: .init(ownerID: "", user: .placeHolder))
        }
        .redacted(reason: .placeholder)
      } else {
        #if os(macOS)
          let editable = !viewModel.users.isEmpty
        #else
          let editable = editMode?.wrappedValue.isEditing == true && !viewModel.users.isEmpty
        #endif

        if editable {
          Section {
            if selectedUserIDs.count != viewModel.users.count {
              Button {
                selectedUserIDs = Set(viewModel.users.map(\.id))
              } label: {
                Text("Select All")
                  .frame(maxWidth: .infinity, alignment: .leading)
              }
            }

            if !selectedUserIDs.isEmpty {
              Button {
                selectedUserIDs = Set()
              } label: {
                Text("DeSelect All")
                  .frame(maxWidth: .infinity, alignment: .leading)
              }

              Button(role: .destructive) {
                Task {
                  await viewModel.deleteUsers(ids: selectedUserIDs)
                }
              } label: {
                Text("Delete Selected User")
                  .frame(maxWidth: .infinity, alignment: .leading)
              }
            }
          }
          .buttonStyle(.borderless)
        }

        ForEach(viewModel.users) { user in
          let viewModel = UserCellViewModel(ownerID: viewModel.userID, user: user)
          UserCellView(viewModel: viewModel)
            .id(user.id)
            .task {
              if self.viewModel.users.last?.id == user.id {
                await self.viewModel.fetchUsers(reset: false)
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
        #if !os(macOS)
          EditButton()
        #endif
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
