//
//  TweetDetailView.swift
//

import SwiftUI

struct TweetDetailView: View {
  @ObservedObject var viewModel: TweetDetailViewModel
  @EnvironmentObject var router: NavigationPathRouter
  
  @ViewBuilder
  func cellView(viewModel: TweetCellViewModel) -> some View {
    VStack {
      TweetCellView(viewModel: viewModel)

      if self.viewModel.cellViewModel.tweetText.id == viewModel.tweetText.id {
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
      
      LikeButton(errorHandle: $viewModel.errorHandle, userID: viewModel.userID, tweetID: viewModel.tweetText.id)
      UnLikeButton(errorHandle: $viewModel.errorHandle, userID: viewModel.userID, tweetID: viewModel.tweetText.id)
      
      BookmarkButton(errorHandle: $viewModel.errorHandle, userID: viewModel.userID, tweetID: viewModel.tweetText.id)
      UnBookmarkButton(errorHandle: $viewModel.errorHandle, userID: viewModel.userID, tweetID: viewModel.tweetText.id)
    }
    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
      Button {
        let tweetDetailViewModel = TweetDetailViewModel(cellViewModel: viewModel)
        router.path.append(tweetDetailViewModel)
      } label: {
        Image(systemName: "ellipsis")
      }
      .tint(.gray)
    }
    .swipeActions(edge: .leading, allowsFullSwipe: true) {
      LikeButton(
        errorHandle: $viewModel.errorHandle, userID: viewModel.userID, tweetID: viewModel.tweetText.id
      )
      .tint(.pink.opacity(0.5))
    }
    .swipeActions(edge: .leading) {
      BookmarkButton(
        errorHandle: $viewModel.errorHandle, userID: viewModel.userID, tweetID: viewModel.tweetText.id
      )
      .tint(.brown.opacity(0.5))
    }
  }

  func adjustDepth(depth: Int) -> Int {
    if depth < 3 {
      return depth
    }
    else {
      return 3
    }
  }
  
  var body: some View {
    if let tweetNode = viewModel.tweetNode {
      List {
        NodeView([tweetNode], children: \.children) { child in
          let viewModel = self.viewModel.getTweetCellViewModel(child.id)
                    
          cellView(viewModel: viewModel)
        }
        .listContentAttribute()
      }
      .scrollViewAttitude()
      .listStyle(.inset)
    } else {
      List {
        cellView(viewModel: viewModel.cellViewModel)
          .listContentAttribute()
      }
      .scrollViewAttitude()
      .listStyle(.inset)
      .task {
        await viewModel.fetchTweets(first: nil, last: nil)
      }
      .alert(errorHandle: $viewModel.errorHandle)
    }
  }
}
