//
//  TopToolBar.swift
//

import Sweet
import SwiftUI

struct TopToolBar: ToolbarContent {
  @Binding var currentUser: Sweet.UserModel?
  @Binding var loginUsers: [Sweet.UserModel]
  @Binding var settings: Settings
  @State var isPresentedSettingsView = false
  @State var isPresentedCreateTweetView = false

  @MainActor
  var body: some ToolbarContent {
    #if !os(macOS)
    if let currentUser {
      ToolbarItem(placement: .navigationBarLeading) {
        LoginMenu(
          bindingCurrentUser: $currentUser,
          loginUsers: $loginUsers,
          settings: $settings,
          currentUser: currentUser
        )
      }
    }
    #endif

#if os(macOS)
let placement: ToolbarItemPlacement = .navigation
#else
let placement: ToolbarItemPlacement = .navigationBarTrailing
#endif
    
    ToolbarItem(placement: placement) {
      Button {
        isPresentedCreateTweetView.toggle()
      } label: {
        Image(systemName: "plus.message")
      }
      .sheet(isPresented: $isPresentedCreateTweetView) {
        let viewModel = NewTweetViewModel(userID: currentUser!.id)
        NewTweetView(viewModel: viewModel)
      }
    }
  }
}
