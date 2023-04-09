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
      TweetsView(viewModel: UserMentionsViewModel(userID: userID, ownerID: userID))
        .id(userID)
        .navigationBarAttribute()
        .navigationTitle("Mention")
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
