//
//  AccountDetailView.swift
//

import Sweet
import SwiftUI

struct AccountDetailView: View {
  @ObservedObject var viewModel: AccountDetailViewModel

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
      .listContentAttribute()
    }
    .scrollViewAttitude()
  }
}
