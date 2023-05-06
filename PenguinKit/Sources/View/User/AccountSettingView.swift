//
//  AccountDetailView.swift
//

import Sweet
import SwiftUI

struct AccountDetailView: View {
  let viewModel: AccountDetailViewModel

  var body: some View {
    List {
      Group {
        let mutingUsersViewModel = MutingUsersViewModel(
          userID: viewModel.userID,
          ownerID: viewModel.user.id
        )
        NavigationLink(value: mutingUsersViewModel) {
          Label("Mute", systemImage: "speaker.slash")
        }

        let blockingUsersViewModel = BlockingUsersViewModel(
          userID: viewModel.userID,
          ownerID: viewModel.user.id
        )
        NavigationLink(value: blockingUsersViewModel) {
          Label("Block", systemImage: "person.crop.circle.badge.xmark")
        }
      }
    }
    .scrollViewAttitude()
  }
}

struct AccountDetailView_Preview: PreviewProvider {
  static var previews: some View {
    NavigationStack {
      AccountDetailView(viewModel: .init(
        userID: "userID",
        user: .init(id: "id", name: "name", userName: "userName")
      ))
    }
  }
}
