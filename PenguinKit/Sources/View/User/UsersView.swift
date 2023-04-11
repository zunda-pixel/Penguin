//
//  UsersView.swift
//

import Sweet
import SwiftUI

struct UsersView<ViewModel: UsersViewProtocol>: View {
  @StateObject var viewModel: ViewModel

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
      await viewModel.fetchUsers(reset: true)
    }
    .task {
      await viewModel.fetchUsers(reset: false)
    }
  }
}
