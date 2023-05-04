//
//  UsersView.swift
//

import Sweet
import SwiftUI

struct UsersView<ViewModel: UsersViewProtocol>: View {
  @StateObject var viewModel: ViewModel
  @State var loadingUsers = false
  
  func fetchUsers(reset: Bool) async {
    guard !loadingUsers else { return }

    loadingUsers.toggle()
    defer { loadingUsers.toggle() }
    
    await viewModel.fetchUsers(reset: reset)
  }

  var body: some View {
    List(viewModel.users) { user in
      UserCellView(ownerID: viewModel.userID, user: user)
        .task {
          if viewModel.users.last?.id == user.id {
            await viewModel.fetchUsers(reset: false)
          }
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
