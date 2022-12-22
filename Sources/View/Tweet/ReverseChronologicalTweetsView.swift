//
//  ReverseChronologicalTweetsView.swift
//

import Sweet
import SwiftUI
import os

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
            await viewModel.fetchTweets(first: nil, last: lastTweet.id)
          }
      }
      .listContentAttribute()
    }
    .overlay(alignment: .topTrailing) {
      if viewModel.notShowTweetCount != 0 {
        Text("\(viewModel.notShowTweetCount)")
          .padding(.horizontal)
          .frame(minWidth: 30)
          .background(settings.colorType.colorSet.tintColor, in: RoundedRectangle(cornerRadius: 14))
          .padding()
      }
    }
    .scrollViewAttitude()
    .listStyle(.plain)
    .alert(errorHandle: $viewModel.errorHandle)
    .refreshable {
      let firstTweetID = viewModel.showTweets.first?.id
      await viewModel.fetchTweets(first: firstTweetID, last: nil)
    }
    .task {
      let firstTweetID = viewModel.showTweets.first?.id
      await viewModel.fetchTweets(first: firstTweetID, last: nil)
    }
  }
}
