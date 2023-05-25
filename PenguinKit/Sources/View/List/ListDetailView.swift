//
//  ListDetailView.swift
//

import Sweet
import SwiftUI

struct ListDetailView: View {
  @StateObject var viewModel: ListDetailViewModel
  @EnvironmentObject var router: NavigationPathRouter

  var listInfoView: some View {
    VStack {
      Text(viewModel.list.name)
      Text(viewModel.list.description!)

      Text("Created At \(Text(viewModel.list.createdAt!, format: .dateTime.year().month().day()))")

      HStack {
        Button {
          let listMembersViewModel = ListMembersViewModel(
            userID: viewModel.userID,
            listID: viewModel.list.id
          )
          router.path.append(listMembersViewModel)
        } label: {
          Text("\(viewModel.list.memberCount!) members")
        }
        Button {
          let listFollowersViewModel = ListFollowersViewModel(
            userID: viewModel.userID,
            listID: viewModel.list.id
          )
          router.path.append(listFollowersViewModel)
        } label: {
          Text("\(viewModel.list.followerCount!) followers")
        }
      }
      .buttonStyle(.bordered)
    }
    .frame(maxWidth: .infinity)
  }

  var body: some View {
    VStack {
      listInfoView
      TweetsView(viewModel: viewModel)
      Spacer()
    }
    .scrollViewAttitude()
    .refreshable {
      await viewModel.fetchTweets(first: viewModel.showTweets.first?.id, last: nil)
    }
    .sceneTask {
      await viewModel.fetchTweets(first: viewModel.showTweets.first?.id, last: nil)
    }
    .toolbar {
      #if os(macOS)
        let placement: ToolbarItemPlacement = .navigation
      #else
        let placement: ToolbarItemPlacement = .navigationBarTrailing
      #endif

      ToolbarItem(placement: placement) {
        let url: URL = .init(string: "https://twitter.com/i/lists/\(viewModel.list.id)")!
        ShareLink(item: url)
      }
    }
  }
}
