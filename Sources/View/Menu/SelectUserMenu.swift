//
//  SelectUserMenu.swift
//

import SwiftUI
import Sweet

struct SelectUserView: View {
  @Environment(\.loginUsers) var loginUsers
  
  @Binding var currentUser: Sweet.UserModel
  
  var body: some View {
    ForEach(loginUsers) { user in
      Button {
        self.currentUser = user
      } label: {
        Label {
          Text("\(user.name) \(user.userName)")
        } icon: {
          ProfileImageView(url: user.profileImageURL!)
            .frame(width: 30, height: 30)
        }
      }
      .disabled(user.id == currentUser.id)
    }
  }
}
