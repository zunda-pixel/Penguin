//
//  TweetDetailView.swift
//

import Sweet
import SwiftUI

struct TweetDetailView: View {
  @StateObject var viewModel: TweetDetailViewModel
  @EnvironmentObject var router: NavigationPathRouter
  @Environment(\.settings) var settings
  @State var scrollContent: ScrollContent<String>?

  func adjustDepth(depth: Int) -> Int {
    if depth < 3 {
      return depth
    } else {
      return 3
    }
  }

  var body: some View {
    ScrollViewReader { proxy in
      List {
        if let tweetNode = viewModel.tweetNode {
          NodeView([tweetNode], children: \.children) { child in
            let viewModel = self.viewModel.getTweetCellViewModel(child.id)
            
            cellView(viewModel: viewModel)
              .listRowInsets(EdgeInsets())
              .id(child.id)
          }
          .listRowSeparator(.hidden)
          .listContentAttribute()
        } else {
          cellView(viewModel: viewModel.cellViewModel)
            .listRowSeparator(.hidden)
            .listContentAttribute()
            .listRowInsets(EdgeInsets())
            .task {
              await viewModel.fetchTweets(first: nil, last: nil)
              scrollContent = ScrollContent(
                contentID: viewModel.cellViewModel.tweet.id,
                anchor: .top
              )
            }
            .alert(errorHandle: $viewModel.errorHandle)
        }
      }
      .onChange(of: scrollContent) { scrollContent in
        guard let scrollContent else { return }
        proxy.scrollTo(scrollContent.contentID, anchor: scrollContent.anchor.unitPoint)
      }
      .scrollViewAttitude()
      .listStyle(.plain)
    }
    .sheet(item: $viewModel.reply) { reply in
      let viewModel: NewTweetViewModel = .init(
        userID: viewModel.userID,
        reply: reply
      )
      NewTweetView(viewModel: viewModel)
    }
  }

  func replyButton(viewModel: TweetCellViewModel) -> some View {
    Button {
      self.viewModel.reply(viewModel: viewModel)
    } label: {
      Label("Reply", systemImage: "arrowshape.turn.up.right")
    }
  }

  @ViewBuilder
  func cellView(viewModel: TweetCellViewModel) -> some View {
    VStack {
      TweetCellView(viewModel: viewModel)
        .padding(EdgeInsets(top: 3, leading: 10, bottom: 0, trailing: 10))

      if self.viewModel.cellViewModel.tweetText.id == viewModel.tweetText.id {
        TweetToolBar(
          viewModel: .init(
            userID: viewModel.userID,
            tweet: viewModel.tweet,
            user: viewModel.author
          )
        )
        //TODO tintでいいはず
        .foregroundColor(settings.colorType.colorSet.tintColor)
        .labelStyle(.iconOnly)
        .padding(5)

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
        .buttonStyle(.plain)
        .tint(.primary)
      }

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

      if viewModel.userID == viewModel.tweetText.authorID {
        Button(role: .destructive) {
          Task {
            await self.viewModel.deleteTweet(viewModel.tweetText.id)
          }
        } label: {
          Label("Delete Tweet", systemImage: "trash")
        }
      }

      if viewModel.tweet.referencedType == .retweet,
        viewModel.author.id == viewModel.userID
      {
        Button(role: .destructive) {
          Task {
            await self.viewModel.deleteReTweet(viewModel.tweetText.id)
          }
        } label: {
          Label("Delete Retweet", systemImage: "trash")
        }
      }

      ReportButton(userName: viewModel.tweetAuthor.userName, tweetID: viewModel.tweetText.id)
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
        errorHandle: $viewModel.errorHandle, userID: viewModel.userID,
        tweetID: viewModel.tweetText.id
      )
      .tint(.secondary)
    }
    .swipeActions(edge: .leading) {
      BookmarkButton(
        errorHandle: $viewModel.errorHandle, userID: viewModel.userID,
        tweetID: viewModel.tweetText.id
      )
      .tint(.secondary)
    }
  }
}
