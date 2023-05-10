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

  @State var scrollContent: ScrollContent<String>?
  @State var displayIDs: Set<String> = []

  var body: some View {
    ScrollViewReader { proxy in
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
            .id(timeline.tweetID!)
            .onAppear { displayIDs.insert(timeline.tweetID!) }
            .onDisappear {
              guard displayIDs.count > 2 else { return }
              displayIDs.remove(timeline.tweetID!)
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
      .onChange(of: scrollContent) { scrollContent in
        guard let scrollContent else { return }
        proxy.scrollTo(scrollContent.contentID, anchor: scrollContent.anchor)
      }
      .scrollViewAttitude()
      .listStyle(.inset)
    }
    .sheet(item: $viewModel.reply) { reply in
      let viewModel = NewTweetViewModel(
        userID: viewModel.userID,
        reply: reply
      )
      NewTweetView(viewModel: viewModel)
    }
    .alert(errorHandle: $viewModel.errorHandle)
    .refreshable {
      await fetchNewTweet()
      setScrollPosition(anchor: .center)
    }
    .task {
      await viewModel.setTimelines()

      if let contentID = Secure.getScrollContentID(userID: viewModel.userID) {
        scrollContent = ScrollContent(
          contentID: contentID,
          anchor: .top
        )
      }
      await fetchNewTweet()
      setScrollPosition(anchor: .top)
    }
    .onDisappear {
      guard let contentID = displayIDs.max() else { return }
      Secure.setScrollContentID(userID: viewModel.userID, contentID: contentID)
    }
  }

  func setScrollPosition(anchor: UnitPoint) {
    guard let id = Array(displayIDs).center() else { return }
    scrollContent = ScrollContent(
      contentID: id,
      anchor: anchor
    )
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
