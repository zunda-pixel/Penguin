//
//  TweetsView.swift
//

import Sweet
import SwiftUI

struct TweetsView<ViewModel: TimelineTweetsProtocol, ListTopContent: View>: View {
  @Environment(\.settings) var settings
  @EnvironmentObject var router: NavigationPathRouter
  @StateObject var viewModel: ViewModel

  @State var displayIDs: Set<String> = []
  @State var scrollContent: ScrollContent<String>?

  let listTopContent: ListTopContent
  let hasTopContent: Bool

  init(viewModel: ViewModel, @ViewBuilder listTopContent: () -> ListTopContent) {
    self._viewModel = .init(wrappedValue: viewModel)
    self.listTopContent = listTopContent()
    self.hasTopContent = true
  }

  init(viewModel: ViewModel) where ListTopContent == EmptyView {
    self._viewModel = .init(wrappedValue: viewModel)
    self.listTopContent = EmptyView()
    self.hasTopContent = false
  }

  func replyButton(viewModel: TweetCellViewModel) -> some View {
    Button {
      self.viewModel.reply(viewModel: viewModel)
    } label: {
      Label("Reply", systemImage: "arrowshape.turn.up.right")
    }
  }

  @ViewBuilder
  var listView: some View {
    List {
      listTopContent
        .listRowSeparator(.hidden)
        .listContentAttribute()

      if viewModel.showTweets.isEmpty && viewModel.loadingTweet {
        ProgressView()
          .controlSize(.large)
          .tint(.secondary)
          .frame(maxWidth: .infinity, maxHeight: .infinity)
          .listRowSeparator(.hidden)
      }

      if viewModel.showTweets.isEmpty && !viewModel.loadingTweet {
        VStack {
          Image(systemName: "info.square")
          Text("No Tweets Found.")
        }
        .frame(maxWidth: .infinity)
        .listRowSeparator(.hidden)
      }

      if viewModel.showTweets.isEmpty && viewModel.loadingTweet {
        ForEach(0..<100) { _ in
          VStack {
            TweetCellView(viewModel: TweetCellViewModel.placeHolder)
              .padding(EdgeInsets(top: 3, leading: 10, bottom: 0, trailing: 10))
            Divider()
          }
          .listRowInsets(EdgeInsets())
          .redacted(reason: .placeholder)
        }
        .listContentAttribute()
        .listRowSeparator(.hidden)
      } else {
        tweetsView
          .listContentAttribute()
          .listRowSeparator(.hidden)
      }
    }
    .if(!hasTopContent) {
      $0.searchable(text: $viewModel.searchSettings.query)
    }
    .scrollViewAttitude()
    .listStyle(.inset)
  }

  var body: some View {
    ScrollViewReader { proxy in
      listView
        .onChange(of: scrollContent) { scrollContent in
          guard let scrollContent else { return }
          proxy.scrollTo(scrollContent.contentID, anchor: scrollContent.anchor.unitPoint)
        }
    }
    .sheet(item: $viewModel.reply) { reply in
      let viewModel = NewTweetViewModel(userID: viewModel.userID, reply: reply)
      NewTweetView(viewModel: viewModel)
    }
    .alert(errorHandle: $viewModel.errorHandle)
    .task {
      guard viewModel.showTweets.isEmpty else { return }
      let firstTweetID = viewModel.showTweets.first?.id
      await viewModel.fetchTweets(first: firstTweetID, last: nil)
    }
    .refreshable {
      let firstTweetID = viewModel.showTweets.first?.id
      await viewModel.fetchTweets(first: firstTweetID, last: nil)
      if let contentID = displayIDs.max() {
        scrollContent = ScrollContent(
          contentID: contentID,
          anchor: .top
        )
      }
    }
  }

  @ViewBuilder
  var tweetsView: some View {
    ForEach(viewModel.showTweets) { tweet in
      let cellViewModel = viewModel.getTweetCellViewModel(tweet.id)

      VStack {
        TweetCellView(viewModel: cellViewModel)
          .padding(EdgeInsets(top: 3, leading: 10, bottom: 0, trailing: 10))
        Divider()
      }
      .id(tweet.id)
      .onAppear { displayIDs.insert(tweet.id) }
      .onDisappear { displayIDs.remove(tweet.id) }
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

        if cellViewModel.userID == cellViewModel.tweetText.authorID {
          Button(role: .destructive) {
            Task {
              await viewModel.deleteTweet(cellViewModel.tweetText.id)
            }
          } label: {
            Label("Delete Tweet", systemImage: "trash")
          }
        }

        if cellViewModel.tweet.referencedType == .retweet,
          cellViewModel.author.id == cellViewModel.userID
        {
          Button(role: .destructive) {
            Task {
              await self.viewModel.deleteReTweet(cellViewModel.tweetText.id)
            }
          } label: {
            Label("Delete Retweet", systemImage: "trash")
          }
        }

        ReportButton(
          userName: cellViewModel.tweetAuthor.userName,
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
      }
      .swipeActions(edge: .leading) {
        BookmarkButton(
          errorHandle: $viewModel.errorHandle,
          userID: viewModel.userID,
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
