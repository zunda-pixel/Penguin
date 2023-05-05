//
//  ListsNavigationView.swift
//

import Sweet
import SwiftUI

struct ListsNavigationView: View {
  @StateObject var router = NavigationPathRouter()

  let userID: String

  @Binding var loginUsers: [Sweet.UserModel]
  @Binding var currentUser: Sweet.UserModel?
  @Binding var settings: Settings

  @State var isPresentedAddList = false

  var body: some View {
    NavigationStack(path: $router.path) {
      ListsView(
        viewModel: ListsViewModel(userID: userID),
        isPresentedAddList: $isPresentedAddList
      )
      .id(userID)
      .navigationBarAttribute()
      .navigationTitle("List")
      .navigationBarTitleDisplayModeIfAvailable(.large)
      .navigationDestination()
      .toolbar {
        if let currentUser {
          #if os(macOS)
            let placement: ToolbarItemPlacement = .navigation
          #else
            let placement: ToolbarItemPlacement = .navigationBarLeading
          #endif

          ToolbarItem(placement: placement) {
            LoginMenu(
              bindingCurrentUser: $currentUser,
              loginUsers: $loginUsers,
              settings: $settings,
              currentUser: currentUser
            )
          }
        }

        #if os(macOS)
          let placement: ToolbarItemPlacement = .navigation
        #else
          let placement: ToolbarItemPlacement = .navigationBarTrailing
        #endif

        ToolbarItem(placement: placement) {
          Button {
            isPresentedAddList.toggle()
          } label: {
            Image(systemName: "plus.app")
          }
        }
      }
    }
    .environmentObject(router)
  }
}
