//
//  LoginMenu.swift
//

import SwiftUI
import Sweet

struct LoginMenu: View {
  @Binding var bindingCurrentUser: Sweet.UserModel?
  @Binding var loginUsers: [Sweet.UserModel]
  @Binding var settings: Settings
  
  @State var isPresentedSettingsView = false
  let currentUser: Sweet.UserModel
  
  var body: some View {
    Menu {
      SelectUserView(currentUser: .init(get: { currentUser }, set: {  bindingCurrentUser = $0 }))
        .onChange(of: bindingCurrentUser) { newValue in
          Secure.currentUser = newValue
        }

      Button {
        isPresentedSettingsView.toggle()
      } label: {
        Label("Settings", systemImage: "gear")
      }
    } label: {
      ProfileImageView(url: currentUser.profileImageURL!)
        .frame(width: 35, height: 35)
        .tint(.secondary)
    }
    .sheet(isPresented: $isPresentedSettingsView) {
      SettingsView(settings: $settings, currentUser: $bindingCurrentUser, loginUsers: $loginUsers)
    }
  }
}
