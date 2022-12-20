//
//  ReverseChronologicalTweetsView.swift
//

import Sweet
import SwiftUI
import os

struct ReverseChronologicalTweetsView<ViewModel: ReverseChronologicalTweetsViewProtocol>: View {
  @EnvironmentObject var router: NavigationPathRouter
  @ObservedObject var viewModel: ViewModel
  
  var body: some View {
    List {
      ForEach(viewModel.showTweets) { tweet in
        let cellViewModel = viewModel.getTweetCellViewModel(tweet.id!)
        
        VStack {
          TweetCellView(viewModel: cellViewModel)
          Divider()
        }
          .swipeActions(edge: .leading, allowsFullSwipe: true) {
            LikeButton(errorHandle: $viewModel.errorHandle, userID: viewModel.userID, tweetID: tweet.id!)
              .tint(.secondary)
              .labelStyle(.iconOnly)
          }
          .swipeActions(edge: .leading) {
            BookmarkButton(errorHandle: $viewModel.errorHandle, userID: viewModel.userID, tweetID: tweet.id!)
              .tint(.secondary)
              .labelStyle(.iconOnly)
          }
          .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            Button {
              let tweetDetailViewModel: TweetDetailViewModel = .init(cellViewModel: cellViewModel)
              router.path.append(tweetDetailViewModel)
            } label: {
              Image(systemName: "ellipsis")
            }
            .tint(.gray)
          }
          .task {
            guard let lastTweet = viewModel.showTweets.last else { return }
            guard tweet.id == lastTweet.id else { return }
            await viewModel.fetchTweets(first: nil, last: lastTweet.id, nextToken: nil)
          }
      }
      .listContentAttribute()
    }
    .scrollViewAttitude()
    .listStyle(.plain)
    .alert(errorHandle: $viewModel.errorHandle)
    .refreshable {
      let firstTweetID = viewModel.showTweets.first?.id
      await viewModel.fetchTweets(first: firstTweetID, last: nil, nextToken: nil)
    }
    .task {
      let firstTweetID = viewModel.showTweets.first?.id
      await viewModel.fetchTweets(first: firstTweetID, last: nil, nextToken: nil)
    }
  }
}
