//
//  AccountDetailView.swift
//

import Sweet
import SwiftUI

struct AccountDetailView: View {
  let userID: String
  let user: Sweet.UserModel

  var body: some View {
    List {
      Group {
        let mutingUsersViewModel = MutingUsersViewModel(
          userID: userID,
          ownerID: user.id
        )
        NavigationLink(value: mutingUsersViewModel) {
          Label("Mute", systemImage: "speaker.slash")
        }

        let blockingUsersViewModel = BlockingUsersViewModel(
          userID: userID,
          ownerID: user.id
        )
        NavigationLink(value: blockingUsersViewModel) {
          Label("Block", systemImage: "person.crop.circle.badge.xmark")
        }
      }
      .listContentAttribute()
    }
    .scrollViewAttitude()
  }
}

struct AccountDetailView_Preview: PreviewProvider {
  static var previews: some View {
    NavigationStack {
      AccountDetailView(
        userID: "userID",
        user: .init(id: "id", name: "name", userName: "userName")
      )
    }
  }
}
