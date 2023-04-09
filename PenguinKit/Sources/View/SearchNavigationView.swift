//
//  SearchView.swift
//

import Sweet
import SwiftUI

struct SearchNavigationView: View {
  @StateObject var router = NavigationPathRouter()

  let userID: String
  
  @Binding var loginUsers: [Sweet.UserModel]
  @Binding var currentUser: Sweet.UserModel?
  @Binding var settings: Settings

  var body: some View {
    NavigationStack(path: $router.path) {
      let viewModel = SearchViewModel(
        userID: userID,
        searchSettings: .init(excludeRetweet: true)
      )
      SearchView(viewModel: viewModel)
        .id(userID)
        .navigationBarAttribute()
        .scrollViewAttitude()
        .scrollDismissesKeyboard(.immediately)
        .navigationTitle("Search")
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
