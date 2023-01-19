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
            await viewModel.tweetCellOnAppear(tweet: cellViewModel.tweet)
          }
      }
      .listContentAttribute()
    }
    .searchable(text: $viewModel.searchSettings.query)
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
      await viewModel.fetchNewTweet()
    }
    .task {
      await viewModel.fetchNewTweet()
    }
  }
}
