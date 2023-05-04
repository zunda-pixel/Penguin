//
// OnlineUserDetailView.swift
//

import SwiftUI

struct OnlineUserDetailView: View {
  @StateObject var viewModel: OnlineUserDetailViewModel
  @State var loadingUser = false
  
  func fetchUser() async {
    guard !loadingUser else { return }

    loadingUser.toggle()
    defer { loadingUser.toggle() }
    
    await viewModel.fetchUser()
  }

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
      await fetchUser()
    }
  }
}
