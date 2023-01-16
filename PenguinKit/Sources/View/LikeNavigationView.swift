//
//  LikeNavigationView.swift
//

import Sweet
import SwiftUI

struct LikeNavigationView: View {
  @StateObject var router = NavigationPathRouter()

  @Binding var loginUsers: [Sweet.UserModel]
  @Binding var currentUser: Sweet.UserModel?
  @Binding var settings: Settings

  let userID: String

  var body: some View {
    NavigationStack(path: $router.path) {
      let viewModel: LikesViewModel = .init(userID: userID, ownerID: userID)

      TweetsView(viewModel: viewModel)
        .navigationBarAttribute()
        .navigationTitle("Like")
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination()
        .toolbar {
          TopToolBar(
            currentUser: $currentUser,
            loginUsers: $loginUsers,
            settings: $settings
          )
        }
    }
    .environmentObject(router)
  }
}
