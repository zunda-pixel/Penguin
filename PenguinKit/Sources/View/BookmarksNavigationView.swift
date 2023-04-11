//
//  BookmarksNavigationView.swift
//

import Sweet
import SwiftUI

struct BookmarksNavigationView: View {
  @StateObject var router = NavigationPathRouter()

  let userID: String

  @Binding var loginUsers: [Sweet.UserModel]
  @Binding var currentUser: Sweet.UserModel?
  @Binding var settings: Settings

  var body: some View {
    NavigationStack(path: $router.path) {
      TweetsView(viewModel: BookmarksViewModel(userID: userID))
        .id(userID)
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
