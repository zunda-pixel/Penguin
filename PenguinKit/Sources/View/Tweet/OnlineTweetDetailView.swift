//
//  OnlineTweetDetailView.swift
//

import Sweet
import SwiftUI

struct OnlineTweetDetailView: View {
  @ObservedObject var viewModel: OnlineTweetDetailViewModel
  @EnvironmentObject var router: NavigationPathRouter

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

  @ViewBuilder
  func cellView(viewModel: TweetCellViewModel) -> some View {
    VStack {
      VStack {
        TweetCellView(viewModel: viewModel)

        if self.viewModel.tweetID == viewModel.tweetText.id {
          TweetToolBar(
            viewModel: .init(
              userID: viewModel.userID,
              tweet: viewModel.tweet,
              user: viewModel.author
            )
          )
          .labelStyle(.iconOnly)

          Divider()

          Text(
            viewModel.tweet.createdAt!.formatted(
              date: .abbreviated,
              time: .standard
            ))

          Divider()

          TweetDetailInformation(
            userID: viewModel.userID,
            tweetID: viewModel.tweet.id,
            metrics: viewModel.tweet.publicMetrics!
          )
        }
      }
      .padding(EdgeInsets(top: 3, leading: 10, bottom: 0, trailing: 10))

      Divider()
    }
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

  var body: some View {
    List {
      if let tweetNode = viewModel.tweetNode {
        NodeView([tweetNode], children: \.children) { child in
          let viewModel = self.viewModel.getTweetCellViewModel(child.id)
          cellView(viewModel: viewModel)
            .listRowInsets(EdgeInsets())
        }
        .listRowSeparator(.hidden)
        .listContentAttribute()

      } else {
        ProgressView()
          .listRowSeparator(.hidden)
          .listContentAttribute()
      }
    }
    .listStyle(.inset)
    .scrollViewAttitude()
    .alert(errorHandle: $viewModel.errorHandle)
    .task {
      await viewModel.fetchTweets(first: nil, last: nil)
    }
  }
}
