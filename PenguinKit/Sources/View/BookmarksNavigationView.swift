//
//  BookmarksNavigationView.swift
//

import Sweet
import SwiftUI

struct BookmarksNavigationView: View {
  @StateObject var router = NavigationPathRouter()

  @Binding var loginUsers: [Sweet.UserModel]
  @Binding var currentUser: Sweet.UserModel?
  @Binding var settings: Settings

  let userID: String

  var body: some View {
    NavigationStack(path: $router.path) {
      let viewModel: BookmarksViewModel = .init(userID: userID)

      TweetsView(viewModel: viewModel)
        .navigationBarAttribute()
        .navigationTitle("Bookmark")
        .navigationBarTitleDisplayModeIfAvailable(.inline)
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
