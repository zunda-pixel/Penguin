//
//  SearchSpaceNavigationView.swift
//

import Sweet
import SwiftUI

struct SearchSpaceNavigationView: View {
  @StateObject var router = NavigationPathRouter()

  let userID: String

  @Binding var loginUsers: [Sweet.UserModel]
  @Binding var currentUser: Sweet.UserModel?
  @Binding var settings: Settings

  var body: some View {
    NavigationStack(path: $router.path) {
      SearchSpacesView(viewModel: SearchSpacesViewModel(userID: userID))
        .id(userID)
        .navigationBarAttribute()
        .navigationTitle("Search Space")
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
