//
//  MentionNavigationView.swift
//

import Sweet
import SwiftUI

struct MentionNavigationView: View {
  @StateObject var router = NavigationPathRouter()
  let userID: String

  @Binding var loginUsers: [Sweet.UserModel]
  @Binding var currentUser: Sweet.UserModel?
  @Binding var settings: Settings

  var body: some View {
    NavigationStack(path: $router.path) {
      let viewModel: UserMentionsViewModel = .init(userID: userID, ownerID: userID)

      TweetsView(viewModel: viewModel)
        .navigationBarAttribute()
        .navigationTitle("Mention")
        .navigationBarTitleDisplayModeIfAvailable(.inline)
        .navigationDestination()
        .toolbar {
          TopToolBar(currentUser: $currentUser, loginUsers: $loginUsers, settings: $settings)
        }
    }
    .environmentObject(router)
  }
}
