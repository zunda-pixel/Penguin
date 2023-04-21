//
//  ReverseChronologicalTweetsView.swift
//

import CoreData
import Sweet
import SwiftUI

struct ReverseChronologicalTweetsView<ViewModel: ReverseChronologicalTweetsViewProtocol>: View {
  @EnvironmentObject var router: NavigationPathRouter
  @StateObject var viewModel: ViewModel
  @Environment(\.settings) var settings

  @State var loadingTweets = false

  @ViewBuilder
  func replyButton(viewModel: TweetCellViewModel) -> some View {
    Button {
      let mentions = viewModel.tweet.entity?.mentions ?? []
      let userNames = mentions.map(\.userName)

      // TODO 何故か取得できないユーザーがいる
      let users: [Sweet.UserModel] = userNames.compactMap { userID in
        self.viewModel.getUser(userID)
      }
      let userModels: [Sweet.UserModel] = users + [viewModel.author]

      self.viewModel.reply = Reply(
        replyID: viewModel.tweetText.id,
        ownerID: viewModel.tweetText.authorID!,
        replyUsers: userModels.uniqued(by: \.id)
      )
    } label: {
      Label("Reply", systemImage: "arrowshape.turn.up.right")
    }
  }

  @FetchRequest var timelines: FetchedResults<Timeline>

  init(viewModel: ViewModel) {
    self._viewModel = .init(wrappedValue: viewModel)
    let fetchRequest: NSFetchRequest<Timeline> = .init()
    fetchRequest.entity = Timeline.entity()
    fetchRequest.predicate = .init(format: "ownerID = %@", viewModel.userID)
    fetchRequest.sortDescriptors = [.init(keyPath: \Timeline.tweetID, ascending: false)]
    self._timelines = .init(fetchRequest: fetchRequest)
  }

  var body: some View {
    List {
      ForEach(timelines) { timeline in
        let cellViewModel = viewModel.getTweetCellViewModel(timeline.tweetID!)

        if cellViewModel.isValidateTweet(settings: viewModel.searchSettings) {
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
              errorHandle: $viewModel.errorHandle,
              userID: viewModel.userID,
              tweetID: cellViewModel.tweetText.id
            )
            .tint(.secondary)
            .labelStyle(.iconOnly)
          }
          .swipeActions(edge: .leading) {
            BookmarkButton(
              errorHandle: $viewModel.errorHandle,
              userID: viewModel.userID,
              tweetID: cellViewModel.tweetText.id
            )
            .tint(.secondary)
            .labelStyle(.iconOnly)
          }
          .task {
            if timeline.tweetID == timelines.last?.tweetID {
              await viewModel.fetchTweets(last: timeline.tweetID!, paginationToken: nil)
            }
          }
        }
      }
      .listRowSeparator(.hidden)
      .listContentAttribute()
    }
    .sheet(item: $viewModel.reply) { reply in
      let viewModel = NewTweetViewModel(
        userID: viewModel.userID,
        reply: reply
      )
      NewTweetView(viewModel: viewModel)
    }
    .searchable(text: $viewModel.searchSettings.query)
    .scrollViewAttitude()
    .listStyle(.inset)
    .alert(errorHandle: $viewModel.errorHandle)
    .refreshable {
      await fetchNewTweet()
    }
    .task {
      await fetchNewTweet()
    }
  }

  func fetchNewTweet() async {
    guard !loadingTweets else { return }

    loadingTweets.toggle()

    defer {
      loadingTweets.toggle()
    }

    await viewModel.fetchTweets(last: nil, paginationToken: nil)
  }
}
