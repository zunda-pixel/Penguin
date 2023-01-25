//
//  OnlineTweetDetailView.swift
//

import SwiftUI
import Sweet

struct OnlineTweetDetailView: View {
  @ObservedObject var viewModel: OnlineTweetDetailViewModel
  @EnvironmentObject var router: NavigationPathRouter

  @ViewBuilder
  func cellView(viewModel: TweetCellViewModel) -> some View {
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

        HStack {
          Text(
            viewModel.tweet.createdAt!.formatted(date: .abbreviated, time: .standard)
          )

          // sourceがnilの場合を考慮(APIの仕様変更の可能性があるため)
          if let source = viewModel.tweet.source {
            Text("via \(source)")
          }
        }

        Divider()

        TweetDetailInformation(
          userID: viewModel.userID,
          tweetID: viewModel.tweet.id,
          metrics: viewModel.tweet.publicMetrics!
        )
      }
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
      
      Button {
        let mentions = viewModel.tweet.entity?.mentions ?? []
        let userNames = mentions.map(\.userName)
        let users: [Sweet.UserModel] = userNames.map { userID in self.viewModel.allUsers.first { $0.userName == userID }! }
        
        self.viewModel.reply = Reply(replyID: viewModel.tweetText.id, ownerID: viewModel.tweetText.authorID!, replyUsers: users)
      } label: {
        Label("Reply", systemImage: "arrowshape.turn.up.right")
      }
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
      Button {
        let mentions = viewModel.tweet.entity?.mentions ?? []
        let userNames = mentions.map(\.userName)
        let users: [Sweet.UserModel] = userNames.map { userID in self.viewModel.allUsers.first { $0.userName == userID }! }
        
        self.viewModel.reply = Reply(replyID: viewModel.tweetText.id, ownerID: viewModel.tweetText.authorID!, replyUsers: users)
      } label: {
        Label("Reply", systemImage: "arrowshape.turn.up.right")
          .labelStyle(.iconOnly)
      }
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
        }
        .listContentAttribute()

      } else {
        ProgressView()
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
