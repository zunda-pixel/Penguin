//
// OnlineUserDetailView.swift
//

import SwiftUI

struct OnlineUserDetailView: View {
  @StateObject var viewModel: OnlineUserDetailViewModel

  var body: some View {
    VStack {
      if let user = viewModel.targetUser {
        let viewModel: UserDetailViewModel = .init(userID: viewModel.userID, user: user)

        UserDetailView(viewModel: viewModel)
      } else {
        ProgressView()
      }
    }
    .task {
      await viewModel.fetchUser()
    }
  }
}
