//
//  TweetToolBar.swift
//

import Sweet
import SwiftUI
import os

@MainActor class TweetToolBarViewModel: ObservableObject {
  let userID: String

  let tweet: Sweet.TweetModel
  let user: Sweet.UserModel

  init(userID: String, tweet: Sweet.TweetModel, user: Sweet.UserModel) {
    self.userID = userID
    self.tweet = tweet
    self.user = user
  }

  @Published var errorHandle: ErrorHandle?

  func retweet() async {
    do {
      try await Sweet(userID: userID).retweet(userID: userID, tweetID: tweet.id)
    } catch {
      errorHandle = ErrorHandle(error: error)
    }
  }

  func deleteRetweet() async {
    do {
      try await Sweet(userID: userID).deleteRetweet(userID: userID, tweetID: tweet.id)
    } catch {
      errorHandle = ErrorHandle(error: error)
    }
  }

  func like() async {
    do {
      try await Sweet(userID: userID).like(userID: userID, tweetID: tweet.id)
    } catch {
      errorHandle = ErrorHandle(error: error)
    }
  }

  func unlike() async {
    do {
      try await Sweet(userID: userID).unLike(userID: userID, tweetID: tweet.id)
    } catch {
      errorHandle = ErrorHandle(error: error)
    }
  }

  func addBookmark() async {
    do {
      try await Sweet(userID: userID).addBookmark(userID: userID, tweetID: tweet.id)
    } catch {
      errorHandle = ErrorHandle(error: error)
    }
  }

  func deleteBookmark() async {
    do {
      try await Sweet(userID: userID).deleteBookmark(userID: userID, tweetID: tweet.id)
    } catch {
      errorHandle = ErrorHandle(error: error)
    }
  }
}

struct TweetToolBar: View {
  @ObservedObject var viewModel: TweetToolBarViewModel

  @State var isPresentedNewTweetView = false
  @State var isPresentedRetweetMenu = false
  @State var isPresentedLikeMenu = false
  @State var isPresentedBookmarkMenu = false

  var retweetMenu: some View {
    Menu {
      Button("Retweet") {
        isPresentedRetweetMenu.toggle()
      }

      Button("Quoted Retweet") {
        isPresentedNewTweetView.toggle()
      }
    } label: {
      Label(
        "\(viewModel.tweet.publicMetrics!.retweetCount + viewModel.tweet.publicMetrics!.quoteCount)",
        systemImage: "arrow.2.squarepath"
      )
    }
  }

  var retweetButton: some View {
    Button("Retweet") {
      Task {
        await viewModel.retweet()
      }
    }
  }

  var deleteRetweetButton: some View {
    Button("Delete Retweet") {
      Task {
        await viewModel.deleteRetweet()
      }
    }
  }

  var likeMenu: some View {
    Button {
      isPresentedLikeMenu.toggle()
    } label: {
      Label("Like", systemImage: "heart")
        .labelStyle(.iconOnly)
    }
  }

  var likeButton: some View {
    Button("Like") {
      Task {
        await viewModel.like()
      }
    }
  }

  var unLikeButton: some View {
    Button("UnLike") {
      Task {
        await viewModel.unlike()
      }
    }
  }

  var bookMarkMenu: some View {
    Button {
      isPresentedBookmarkMenu.toggle()
    } label: {
      Label("Bookmark", systemImage: "bookmark")
        .labelStyle(.iconOnly)
    }
  }

  var addBookmarkButton: some View {
    Button("Add Bookmark") {
      Task {
        await viewModel.addBookmark()
      }
    }
  }

  var deleteBookmarkButton: some View {
    Button("Delete Bookmark") {
      Task {
        await viewModel.deleteBookmark()
      }
    }
  }

  var shareButton: some View {
    let url: URL = URL(
      string: "https://twitter.com/\(viewModel.user.id)/status/\(viewModel.tweet.id)"
    )!
    return ShareLink(item: url) {
      Label("Share", systemImage: "square.and.arrow.up")
        .labelStyle(.iconOnly)
    }
  }

  var body: some View {
    HStack {
      retweetMenu
        .frame(maxWidth: .infinity)

      likeMenu
        .frame(maxWidth: .infinity)

      bookMarkMenu
        .frame(maxWidth: .infinity)

      shareButton
        .frame(maxWidth: .infinity)
    }
    .buttonStyle(.plain)
    .confirmationDialog("Retweet", isPresented: $isPresentedRetweetMenu) {
      retweetButton
      deleteRetweetButton
    }
    .confirmationDialog("Like", isPresented: $isPresentedLikeMenu) {
      likeButton
      unLikeButton
    }
    .confirmationDialog("Bookmark", isPresented: $isPresentedBookmarkMenu) {
      addBookmarkButton
      deleteBookmarkButton
    }
    .sheet(isPresented: $isPresentedNewTweetView) {
      let viewModel: NewTweetViewModel = .init(
        userID: viewModel.userID,
        quoted: (viewModel.tweet, viewModel.user)
      )
      NewTweetView(viewModel: viewModel)
    }
    .alert(errorHandle: $viewModel.errorHandle)
  }
}
