//
//  TweetsView.swift
//

import Sweet
import SwiftUI

struct TweetsView<ViewModel: TimelineTweetsProtocol, ListTopContent: View>: View {
  @Environment(\.settings) var settings
  @EnvironmentObject var router: NavigationPathRouter

  @ObservedObject var viewModel: ViewModel
  let listTopContent: ListTopContent
  let hasTopContent: Bool

  init(viewModel: ViewModel, @ViewBuilder listTopContent: () -> ListTopContent) {
    self.viewModel = viewModel
    self.listTopContent = listTopContent()
    self.hasTopContent = true
  }

  init(viewModel: ViewModel) where ListTopContent == EmptyView {
    self.viewModel = viewModel
    self.listTopContent = EmptyView()
    self.hasTopContent = false
  }

  @ViewBuilder
  var listView: some View {
    List {
      listTopContent
        .listContentAttribute()

      if viewModel.showTweets.isEmpty && viewModel.loadingTweet {
        ProgressView()
          .controlSize(.large)
          .tint(.secondary)
          .frame(maxWidth: .infinity, maxHeight: .infinity)
      }

      if viewModel.showTweets.isEmpty && !viewModel.loadingTweet {
        VStack {
          Image(systemName: "info.square")
          Text("No Tweets Found.")
        }
        .frame(maxWidth: .infinity)
      }

      tweetsView
        .listContentAttribute()
    }
    .if(!hasTopContent) {
      $0.searchable(text: $viewModel.searchSettings.query)
    }
    .scrollViewAttitude()
    .listStyle(.inset)
  }

  var body: some View {
    listView
      .sheet(item: $viewModel.reply) { reply in
        let viewModel = NewTweetViewModel(userID: viewModel.userID, reply: reply)
        NewTweetView(viewModel: viewModel)
      }
      .alert(errorHandle: $viewModel.errorHandle)
      .task(id: viewModel.userID) {
        guard viewModel.showTweets.isEmpty else { return }
        let firstTweetID = viewModel.showTweets.first?.id
        await viewModel.fetchTweets(first: firstTweetID, last: nil)
      }
      .refreshable {
        let firstTweetID = viewModel.showTweets.first?.id
        await viewModel.fetchTweets(first: firstTweetID, last: nil)
      }
  }

  @ViewBuilder
  var tweetsView: some View {
    ForEach(viewModel.showTweets) { tweet in
      let cellViewModel = viewModel.getTweetCellViewModel(tweet.id)

      TweetCellView(viewModel: cellViewModel)
        .frame(maxWidth: .infinity)
        .contentShape(Rectangle())
        .contextMenu {
          let url: URL = URL(
            string:
              "https://twitter.com/\(cellViewModel.author.id)/status/\(cellViewModel.tweetText.id)"
          )!
          ShareLink(item: url) {
            Label("Share", systemImage: "square.and.arrow.up")
          }

          LikeButton(
            errorHandle: $viewModel.errorHandle,
            userID: viewModel.userID,
            tweetID: cellViewModel.tweetText.id
          )

          UnLikeButton(
            errorHandle: $viewModel.errorHandle,
            userID: viewModel.userID,
            tweetID: cellViewModel.tweetText.id
          )

          BookmarkButton(
            errorHandle: $viewModel.errorHandle,
            userID: viewModel.userID,
            tweetID: cellViewModel.tweetText.id
          )

          UnBookmarkButton(
            errorHandle: $viewModel.errorHandle,
            userID: viewModel.userID,
            tweetID: cellViewModel.tweetText.id
          )
        }
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
          Button {
            let tweetDetailViewModel = TweetDetailViewModel(cellViewModel: cellViewModel)
            router.path.append(tweetDetailViewModel)
          } label: {
            Image(systemName: "ellipsis")
          }
          .tint(.gray)
        }
        .swipeActions(edge: .trailing) {
          Button {
            let mentions = cellViewModel.tweet.entity?.mentions ?? []
            let userNames = mentions.map(\.userName)
            let users: [Sweet.UserModel] = userNames.map { userID in self.viewModel.allUsers.first { $0.userName == userID }! }

            viewModel.reply = Reply(replyID: cellViewModel.tweetText.id, ownerID: cellViewModel.tweetText.authorID!, replyUsers: users)
          } label: {
            Image(systemName: "arrowshape.turn.up.right")
          }
          .tint(.gray)
        }
        .swipeActions(edge: .leading, allowsFullSwipe: true) {
          LikeButton(
            errorHandle: $viewModel.errorHandle, userID: viewModel.userID,
            tweetID: cellViewModel.tweetText.id
          )
          .tint(.secondary)
        }
        .swipeActions(edge: .leading) {
          BookmarkButton(
            errorHandle: $viewModel.errorHandle, userID: viewModel.userID,
            tweetID: cellViewModel.tweetText.id
          )
          .tint(.secondary)
        }
        .task {
          guard let lastTweet = viewModel.showTweets.last else { return }
          guard tweet.id == lastTweet.id else { return }
          await viewModel.fetchTweets(first: nil, last: lastTweet.id)
        }
    }
  }
}
