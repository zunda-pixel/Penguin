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
  func replyButton(viewModel: TweetCellViewModel) -> some View {
    Button {
      let mentions = viewModel.tweet.entity?.mentions ?? []
      let userNames = mentions.map(\.userName)
      let users: [Sweet.UserModel] =
        userNames.map { userID in self.viewModel.allUsers.first { $0.userName == userID }! } + [
          viewModel.author
        ]

      self.viewModel.reply = Reply(
        replyID: viewModel.tweetText.id, ownerID: viewModel.tweetText.authorID!,
        replyUsers: users.uniqued(by: \.id))
    } label: {
      Label("Reply", systemImage: "arrowshape.turn.up.right")
    }
  }

  var body: some View {
    TweetsView(viewModel: viewModel) {
      userProfile
        .padding()
        .buttonStyle(.bordered)
        .buttonBorderShape(.roundedRectangle)
        .listRowInsets(EdgeInsets())

      if let pinnedTweetID = viewModel.pinnedTweetID {
        let viewModel = viewModel.getTweetCellViewModel(pinnedTweetID)
        VStack(spacing: 0) {
          Divider()
          VStack(alignment: .leading, spacing: 0) {
            Text("\(Image(systemName: "pin.fill")) Pinned Tweet")
              .font(.caption)
              .foregroundColor(.secondary)
              .padding(EdgeInsets(top: 0, leading: 20, bottom: 5, trailing: 0))

            TweetCellView(viewModel: viewModel)
          }
          .padding(EdgeInsets(top: 3, leading: 10, bottom: 0, trailing: 10))

          Divider()
        }
        .listRowInsets(EdgeInsets())
        .contextMenu {
          let url: URL = URL(
            string: "https://twitter.com/\(viewModel.author.id)/status/\(viewModel.tweetText.id)"
          )!
          ShareLink(item: url) {
            Label("Share", systemImage: "square.and.arrow.up")
          }

          LikeButton(
            errorHandle: $viewModel.errorHandle,
            userID: viewModel.userID,
            tweetID: viewModel.tweetText.id
          )

          UnLikeButton(
            errorHandle: $viewModel.errorHandle,
            userID: viewModel.userID,
            tweetID: viewModel.tweetText.id
          )

          BookmarkButton(
            errorHandle: $viewModel.errorHandle,
            userID: viewModel.userID,
            tweetID: viewModel.tweetText.id
          )

          UnBookmarkButton(
            errorHandle: $viewModel.errorHandle,
            userID: viewModel.userID,
            tweetID: viewModel.tweetText.id
          )

          replyButton(viewModel: viewModel)
        }
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
          Button {
            let tweetDetailViewModel = TweetDetailViewModel(cellViewModel: viewModel)
            router.path.append(tweetDetailViewModel)
          } label: {
            Image(systemName: "ellipsis")
          }
          .tint(.secondary)
        }
        .swipeActions(edge: .trailing) {
          replyButton(viewModel: viewModel)
            .labelStyle(.iconOnly)
            .tint(.secondary)
        }
        .swipeActions(edge: .leading, allowsFullSwipe: true) {
          LikeButton(
            errorHandle: $viewModel.errorHandle,
            userID: viewModel.userID,
            tweetID: viewModel.tweetText.id
          )
          .tint(.secondary)
        }
        .swipeActions(edge: .leading) {
          BookmarkButton(
            errorHandle: $viewModel.errorHandle,
            userID: viewModel.userID,
            tweetID: viewModel.tweetText.id
          )
          .tint(.secondary)
        }
      }
    }
    .toolbar {
      if viewModel.userID != viewModel.user.id {
        #if os(macOS)
          let placement: ToolbarItemPlacement = .navigation
        #else
          let placement: ToolbarItemPlacement = .navigationBarTrailing
        #endif

        ToolbarItem(placement: placement) {
          UserToolMenu(
            fromUserID: viewModel.userID,
            toUserID: viewModel.user.id
          )
        }
      }
    }
    .task {
      await viewModel.fetchPinnedTweet()
    }
  }
}
