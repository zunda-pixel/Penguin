//
//  ReverseChronologicalTweetsView.swift
//

import Sweet
import SwiftUI

struct ReverseChronologicalTweetsView<ViewModel: ReverseChronologicalTweetsViewProtocol>: View {
  @EnvironmentObject var router: NavigationPathRouter
  @StateObject var viewModel: ViewModel
  @Environment(\.settings) var settings

  @State var loadingTweets = false

  var body: some View {
    List {
      if viewModel.timelines.isEmpty && loadingTweets {
        ForEach(0..<100) { _ in
          VStack {
            TweetCellView(viewModel: TweetCellViewModel.placeHolder)
              .padding(EdgeInsets(top: 3, leading: 10, bottom: 0, trailing: 10))
            Divider()
          }
          .listRowInsets(EdgeInsets())
          .redacted(reason: .placeholder)
        }
      } else {
        ForEach(viewModel.timelines) { timeline in
          VStack {
            PlaceHolderTweetCellView(
              userID: viewModel.userID,
              tweetID: timeline.tweetID!,
              errorHandle: $viewModel.errorHandle,
              reply: $viewModel.reply
            )
            .padding(EdgeInsets(top: 3, leading: 10, bottom: 0, trailing: 10))
            Divider()
          }
          .listRowInsets(EdgeInsets())
          .task {
            if timeline.tweetID == viewModel.timelines.last?.tweetID {
              await viewModel.fetchTweets(last: timeline.tweetID!, paginationToken: nil)
            }
          }
        }
        .listRowSeparator(.hidden)
        .listContentAttribute()
      }
    }
    .sheet(item: $viewModel.reply) { reply in
      let viewModel = NewTweetViewModel(
        userID: viewModel.userID,
        reply: reply
      )
      NewTweetView(viewModel: viewModel)
    }
    .scrollViewAttitude()
    .listStyle(.inset)
    .alert(errorHandle: $viewModel.errorHandle)
    .refreshable {
      await fetchNewTweet()
    }
    .task {
      await viewModel.setTimelines()
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
