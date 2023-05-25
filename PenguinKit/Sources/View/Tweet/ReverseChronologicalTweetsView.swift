//
//  ReverseChronologicalTweetsView.swift
//

import Sweet
import SwiftUI

struct ReverseChronologicalTweetsView<ViewModel: ReverseChronologicalTweetsViewProtocol>: View {
  @EnvironmentObject var router: NavigationPathRouter
  @StateObject var viewModel: ViewModel
  @Environment(\.settings) var settings
  @Environment(\.scenePhase) var scenePhase
  @State var launchBackground = true
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
              let viewModel = viewModel.tweetCellViewModel(tweetCell: timeline.tweetCell!)
              tweetCellView(viewModel: viewModel)
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
              if timeline.tweetID! == viewModel.timelines.last?.tweetID {
                await viewModel.fetchTweets(
                  last: timeline.tweetID!,
                  paginationToken: nil
                )
              }
            }
          }
          .listRowSeparator(.hidden)
          .listContentAttribute()
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
      let viewModel = NewTweetViewModel(
        userID: viewModel.userID,
        reply: reply
      )
      NewTweetView(viewModel: viewModel)
    }
    .alert(errorHandle: $viewModel.errorHandle)
    .refreshable {
      await fetchNewTweet()
      setScrollPosition(anchor: .top)
    }
    .onChange(of: scenePhase) { scenePhase in
      if scenePhase == .background {
        launchBackground = true
      }
    }
    .task(id: scenePhase) {
      guard launchBackground, scenePhase == .active else { return }
      launchBackground = false
      await viewModel.setTimelines()
      await fetchNewTweet()
      setScrollPosition(anchor: .top)
    }
  }

  @ViewBuilder
  func tweetCellView(viewModel: TweetCellViewModel) -> some View {
    TweetCellView(viewModel: viewModel)
      .contextMenu {
        let url: URL = URL(
          string:
            "https://twitter.com/\(viewModel.author.id)/status/\(viewModel.tweetText.id)"
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

        Button {
          Task {
            self.viewModel.reply = await self.viewModel.reply(viewModel: viewModel)
          }
        } label: {
          Label("Reply", systemImage: "arrowshape.turn.up.right")
        }
        .labelStyle(.iconOnly)
        .tint(.secondary)

        if viewModel.userID == viewModel.tweetText.authorID {
          Button(role: .destructive) {
            Task {
              do {
                try await Sweet(userID: viewModel.userID).deleteTweet(of: viewModel.tweetText.id)
              } catch {
                let errorHandle = ErrorHandle(error: error)
                errorHandle.log()
                self.viewModel.errorHandle = errorHandle
              }
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
              do {
                try await Sweet(userID: viewModel.userID).deleteTweet(of: viewModel.tweetText.id)
              } catch {
                let errorHandle = ErrorHandle(error: error)
                errorHandle.log()
                self.viewModel.errorHandle = errorHandle
              }
            }
          } label: {
            Label("Delete Retweet", systemImage: "trash")
          }
        }

        ReportButton(userName: viewModel.tweetAuthor.userName, tweetID: viewModel.tweetText.id)
      }
      .swipeActions(edge: .trailing, allowsFullSwipe: true) {
        Button {
          let tweetDetailViewModel: TweetDetailViewModel = .init(cellViewModel: viewModel)
          router.path.append(tweetDetailViewModel)
        } label: {
          Image(systemName: "ellipsis")
        }
        .tint(.secondary)
      }
      .swipeActions(edge: .trailing) {
        Button {
          Task {
            self.viewModel.reply = await self.viewModel.reply(viewModel: viewModel)
          }
        } label: {
          Label("Reply", systemImage: "arrowshape.turn.up.right")
        }
        .labelStyle(.iconOnly)
        .tint(.secondary)
      }
      .swipeActions(edge: .leading, allowsFullSwipe: true) {
        LikeButton(
          errorHandle: $viewModel.errorHandle,
          userID: viewModel.userID,
          tweetID: viewModel.tweetText.id
        )
        .tint(.secondary)
        .labelStyle(.iconOnly)
      }
      .swipeActions(edge: .leading) {
        BookmarkButton(
          errorHandle: $viewModel.errorHandle,
          userID: viewModel.userID,
          tweetID: viewModel.tweetText.id
        )
        .tint(.secondary)
        .labelStyle(.iconOnly)
      }
  }

  func setScrollPosition(anchor: ScrollPoint) {
    let id: String?

    switch anchor {
    case .top: id = Array(displayIDs).max()
    case .center: id = Array(displayIDs).center()
    case .bottom: id = Array(displayIDs).min()
    }

    guard let id else { return }

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
