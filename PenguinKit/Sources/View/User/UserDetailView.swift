//
//  UserView.swift
//

import Sweet
import SwiftUI

struct UserDetailView: View {
  @ObservedObject var viewModel: UserDetailViewModel

  @EnvironmentObject var router: NavigationPathRouter

  var userProfile: some View {
    VStack {
      ProfileImageView(url: viewModel.user.profileImageURL!)
        .frame(width: 100, height: 100)

      UserProfileView(viewModel: .init(user: viewModel.user))

      Button {
        let dmViewModel = DirectMessageDetailViewModel(
          participantID: viewModel.user.id,
          userID: viewModel.userID
        )
        router.path.append(dmViewModel)
      } label: {
        Label("DirectMessage", systemImage: "envelope.fill").frame(maxWidth: .infinity)
      }

      HStack {
        Button {
          let viewModel: FollowerUserViewModel = .init(
            userID: viewModel.userID,
            ownerID: viewModel.user.id
          )
          router.path.append(viewModel)
        } label: {
          VStack {
            Label("FOLLOWERS", systemImage: "figure.wave")
            Text("\(viewModel.user.metrics!.followersCount)")
          }.frame(maxWidth: .infinity)
        }

        Button {
          let viewModel: FollowingUserViewModel = .init(
            userID: viewModel.userID,
            ownerID: viewModel.user.id
          )
          router.path.append(viewModel)
        } label: {
          VStack {
            Label("FOLLOWING", systemImage: "figure.walk")
            Text("\(viewModel.user.metrics!.followingCount)")
          }.frame(maxWidth: .infinity)
        }
      }

      HStack {
        Button {
          let viewModel = LikesViewModel(
            userID: viewModel.userID,
            ownerID: viewModel.user.id
          )
          router.path.append(viewModel)
        } label: {
          Label("Like", systemImage: "heart").frame(maxWidth: .infinity)
        }
        Button {
          let viewModel = UserListViewModel(
            userID: viewModel.userID,
            ownerID: viewModel.user.id
          )
          router.path.append(viewModel)
        } label: {
          Label("List", systemImage: "list.dash.header.rectangle").frame(maxWidth: .infinity)
        }
      }

      HStack {
        Button {
          let viewModel = UserMentionsViewModel(
            userID: viewModel.userID, ownerID: viewModel.user.id)
          router.path.append(viewModel)
        } label: {
          Label("Mention", systemImage: "ellipsis.message").frame(maxWidth: .infinity)
        }

        Button {
          let viewModel = UserTweetsViewModel(viewModel: viewModel)
          router.path.append(viewModel)
        } label: {
          Label("All Tweets", systemImage: "list.dash.header.rectangle").frame(maxWidth: .infinity)
        }
      }
    }
  }

  @ViewBuilder
  var pinnedTweet: some View {
    if let pinnedTweetID = viewModel.pinnedTweetID {
      let viewModel = viewModel.getTweetCellViewModel(pinnedTweetID)
      VStack(alignment: .leading) {
        Text("\(Image(systemName: "pin.fill")) Pinned Tweet")
        TweetCellView(viewModel: viewModel)
      }
    }
  }

  var body: some View {
    TweetsView(viewModel: viewModel) {
      userProfile
        .buttonStyle(.bordered)
        .buttonBorderShape(.roundedRectangle)

      pinnedTweet
    }
    .toolbar {
      if viewModel.userID != viewModel.user.id {
        #if os(macOS)
          let placement: ToolbarItemPlacement = .navigation
        #else
          let placement: ToolbarItemPlacement = .navigationBarTrailing
        #endif

        ToolbarItem(placement: placement) {
          UserToolMenu(fromUserID: viewModel.userID, toUserID: viewModel.user.id)
        }
      }
    }
    .task {
      await viewModel.fetchPinnedTweet()
    }
  }
}
