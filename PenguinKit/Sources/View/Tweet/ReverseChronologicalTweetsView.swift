//
//  ReverseChronologicalTweetsView.swift
//

import Sweet
import SwiftUI

struct ReverseChronologicalTweetsView<ViewModel: ReverseChronologicalTweetsViewProtocol>: View {
  @EnvironmentObject var router: NavigationPathRouter
  @ObservedObject var viewModel: ViewModel
  @Environment(\.settings) var settings

  @ViewBuilder
  func replyButton(viewModel: TweetCellViewModel) -> some View {
    Button {
      let mentions = viewModel.tweet.entity?.mentions ?? []
      let userNames = mentions.map(\.userName)
      let users: [User] = userNames.map { userID in self.viewModel.allUsers.first { $0.userName == userID }! }
      let userModels: [Sweet.UserModel] = users.map { Sweet.UserModel(user: $0) } + [viewModel.author]
      
      self.viewModel.reply = Reply(replyID: viewModel.tweetText.id, ownerID: viewModel.tweetText.authorID!, replyUsers: userModels.uniqued(by: \.id))
    } label: {
      Label("Reply", systemImage: "arrowshape.turn.up.right")
    }
  }
  
  var body: some View {
    List {
      ForEach(viewModel.showTweets) { tweet in
        let cellViewModel = viewModel.getTweetCellViewModel(tweet.id!)

        VStack {
          TweetCellView(viewModel: cellViewModel)
            .padding(EdgeInsets(top: 3, leading: 10, bottom: 0, trailing: 10))
          Divider()
        }
          .listRowInsets(EdgeInsets())
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
            
            replyButton(viewModel: cellViewModel)
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
            replyButton(viewModel: cellViewModel)
              .labelStyle(.iconOnly)
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
      .listRowSeparator(.hidden)
      .listContentAttribute()
    }
    .sheet(item: $viewModel.reply) { reply in
      let viewModel = NewTweetViewModel(userID: viewModel.userID, reply: reply)
      NewTweetView(viewModel: viewModel)
    }
    .searchable(text: $viewModel.searchSettings.query)
    .scrollViewAttitude()
    .listStyle(.inset)
    .alert(errorHandle: $viewModel.errorHandle)
    .refreshable {
      await viewModel.fetchNewTweet()
    }
    .task {
      await viewModel.fetchNewTweet()
    }
  }
}
