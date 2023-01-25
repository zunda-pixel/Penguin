//
//  ReverseChronologicalTweetsView.swift
//

import Sweet
import SwiftUI

struct ReverseChronologicalTweetsView<ViewModel: ReverseChronologicalTweetsViewProtocol>: View {
  @EnvironmentObject var router: NavigationPathRouter
  @ObservedObject var viewModel: ViewModel
  @Environment(\.settings) var settings

  var body: some View {
    List {
      ForEach(viewModel.showTweets) { tweet in
        let cellViewModel = viewModel.getTweetCellViewModel(tweet.id!)

        TweetCellView(viewModel: cellViewModel)
          .frame(maxWidth: .infinity)
          .contextMenu {
            let url: URL = URL(
              string:
                "https://twitter.com/\(cellViewModel.author.id)/status/\(cellViewModel.tweetText.id)"
            )!
            ShareLink(item: url) {
              Label("Share", systemImage: "square.and.arrow.up")
            }

            LikeButton(
              errorHandle: $viewModel.errorHandle, userID: viewModel.userID,
              tweetID: cellViewModel.tweetText.id)
            UnLikeButton(
              errorHandle: $viewModel.errorHandle, userID: viewModel.userID,
              tweetID: cellViewModel.tweetText.id)

            BookmarkButton(
              errorHandle: $viewModel.errorHandle, userID: viewModel.userID,
              tweetID: cellViewModel.tweetText.id)
            UnBookmarkButton(
              errorHandle: $viewModel.errorHandle, userID: viewModel.userID,
              tweetID: cellViewModel.tweetText.id)
            
            Button {
              let mentions = cellViewModel.tweet.entity?.mentions ?? []
              let userNames = mentions.map(\.userName)
              let users: [User] = userNames.map { userID in self.viewModel.allUsers.first { $0.userName == userID }! }
              let userModels: [Sweet.UserModel] = users.map { .init(user: $0) }
              
              viewModel.reply = Reply(replyID: cellViewModel.tweetText.id, ownerID: cellViewModel.tweetText.authorID!, replyUsers: userModels)
            } label: {
              Label("Reply", systemImage: "arrowshape.turn.up.right")
            }
          }
          .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            Button {
              let tweetDetailViewModel: TweetDetailViewModel = .init(cellViewModel: cellViewModel)
              router.path.append(tweetDetailViewModel)
            } label: {
              Image(systemName: "ellipsis")
            }
            .tint(.secondary)
          }
          .swipeActions(edge: .trailing) {
            Button {
              let mentions = cellViewModel.tweet.entity?.mentions ?? []
              let userNames = mentions.map(\.userName)
              let users: [User] = userNames.map { userID in self.viewModel.allUsers.first { $0.userName == userID }! }
              let userModels: [Sweet.UserModel] = users.map { .init(user: $0) }
              
              viewModel.reply = Reply(replyID: cellViewModel.tweetText.id, ownerID: cellViewModel.tweetText.authorID!, replyUsers: userModels)
            } label: {
              Label("Reply", systemImage: "arrowshape.turn.up.right")
                .labelStyle(.iconOnly)
            }
            .tint(.secondary)
          }
          .swipeActions(edge: .leading, allowsFullSwipe: true) {
            LikeButton(
              errorHandle: $viewModel.errorHandle, userID: viewModel.userID,
              tweetID: cellViewModel.tweetText.id
            )
            .tint(.secondary)
            .labelStyle(.iconOnly)
          }
          .swipeActions(edge: .leading) {
            BookmarkButton(
              errorHandle: $viewModel.errorHandle, userID: viewModel.userID,
              tweetID: cellViewModel.tweetText.id
            )
            .tint(.secondary)
            .labelStyle(.iconOnly)
          }
          .task {
            await viewModel.tweetCellOnAppear(tweet: cellViewModel.tweet)
          }
      }
      .listContentAttribute()
    }
    .sheet(item: $viewModel.reply) { reply in
      let viewModel = NewTweetViewModel(userID: viewModel.userID, reply: reply)
      NewTweetView(viewModel: viewModel)
    }
    .searchable(text: $viewModel.searchSettings.query)
    .scrollViewAttitude()
    .listStyle(.plain)
    .alert(errorHandle: $viewModel.errorHandle)
    .refreshable {
      await viewModel.fetchNewTweet()
    }
    .task {
      await viewModel.fetchNewTweet()
    }
  }
}
