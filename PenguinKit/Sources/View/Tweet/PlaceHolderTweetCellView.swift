//
//  PlaceHolderTweetCellView.swift
//

import Sweet
import SwiftUI

struct PlaceHolderTweetCellView: View {
  let userID: String
  let tweetID: String
  let provider: TweetCellViewProvider = TweetCellViewProvider()

  @State var viewModel: TweetCellViewModel?
  @EnvironmentObject var router: NavigationPathRouter
  @Binding var errorHandle: ErrorHandle?
  @Binding var reply: Reply?

  var body: some View {
    if let viewModel {
      cellView(viewModel: viewModel)
    } else {
      TweetCellView(viewModel: TweetCellViewModel.placeHolder)
        .redacted(reason: .placeholder)
        .task {
          viewModel = await provider.getTweetCellViewModel(userID: userID, tweetID: tweetID)
        }
    }
  }

  @ViewBuilder
  func cellView(viewModel: TweetCellViewModel) -> some View {
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
          errorHandle: $errorHandle,
          userID: viewModel.userID,
          tweetID: viewModel.tweetText.id
        )
        UnLikeButton(
          errorHandle: $errorHandle,
          userID: viewModel.userID,
          tweetID: viewModel.tweetText.id
        )
        BookmarkButton(
          errorHandle: $errorHandle,
          userID: viewModel.userID,
          tweetID: viewModel.tweetText.id
        )
        UnBookmarkButton(
          errorHandle: $errorHandle,
          userID: viewModel.userID,
          tweetID: viewModel.tweetText.id
        )

        replyButton(viewModel: viewModel)

        if viewModel.userID == viewModel.tweetText.authorID {
          Button(role: .destructive) {
            Task {
              do {
                try await Sweet(userID: viewModel.userID).deleteTweet(of: viewModel.tweetText.id)
              } catch {
                let errorHandle = ErrorHandle(error: error)
                errorHandle.log()
                self.errorHandle = errorHandle
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
                self.errorHandle = errorHandle
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
        replyButton(viewModel: viewModel)
          .labelStyle(.iconOnly)
          .tint(.secondary)
      }
      .swipeActions(edge: .leading, allowsFullSwipe: true) {
        LikeButton(
          errorHandle: $errorHandle,
          userID: viewModel.userID,
          tweetID: viewModel.tweetText.id
        )
        .tint(.secondary)
        .labelStyle(.iconOnly)
      }
      .swipeActions(edge: .leading) {
        BookmarkButton(
          errorHandle: $errorHandle,
          userID: viewModel.userID,
          tweetID: viewModel.tweetText.id
        )
        .tint(.secondary)
        .labelStyle(.iconOnly)
      }
  }

  @ViewBuilder
  func replyButton(viewModel: TweetCellViewModel) -> some View {
    Button {
      let mentions = viewModel.tweet.entity?.mentions ?? []
      let userNames = mentions.map(\.userName)

      Task {
        let users: [Sweet.UserModel] = await provider.backgroundContext.perform {
          provider.getUsers(screenIDs: userNames)
        }

        let userModels: [Sweet.UserModel] = users + [viewModel.author]

        let tweetContent = TweetContentModel(
          tweet: viewModel.tweetText, author: viewModel.tweetAuthor)

        self.reply = Reply(
          tweetContent: tweetContent,
          replyUsers: userModels.uniqued(by: \.id)
        )
      }
    } label: {
      Label("Reply", systemImage: "arrowshape.turn.up.right")
    }
  }
}
