//
//  ReverseChronologicalNavigationView.swift
//

import Kingfisher
import Sweet
import SwiftUI

struct ReverseChronologicalNavigationView: View {
  @Environment(\.managedObjectContext) var viewContext

  @StateObject var router = NavigationPathRouter()

  @Binding var loginUsers: [Sweet.UserModel]
  @Binding var currentUser: Sweet.UserModel?
  @Binding var settings: Settings

  let userID: String

  var body: some View {
    NavigationStack(path: $router.path) {
      ReverseChronologicalTweetsView(viewModel: ReverseChronologicalViewModel(userID: userID))
        .id(userID)
        .navigationTitle("Timeline")
        .navigationBarTitleDisplayModeIfAvailable(.inline)
        .navigationDestination()
        .toolbar {
          TopToolBar(
            currentUser: $currentUser,
            loginUsers: $loginUsers,
            settings: $settings
          )
        }
        .navigationBarAttribute()
    }
    .environmentObject(router)
  }
}
