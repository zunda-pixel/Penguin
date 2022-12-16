//
//  TweetView.swift
//

import Kingfisher
import Sweet
import SwiftUI
import os

struct TweetCellView<ViewModel: TweetCellViewProtocol>: View {
  @Environment(\.openURL) private var openURL

  @EnvironmentObject var router: NavigationPathRouter

  @ObservedObject var viewModel: ViewModel

  var body: some View {
    let isRetweeted = viewModel.tweet.referencedTweets.contains(where: { $0.type == .retweeted })

    let user = isRetweeted ? viewModel.retweet!.user : viewModel.author

    HStack(alignment: .top) {
      ProfileImageView(url: user.profileImageURL!)
        .frame(width: 50, height: 50)
        .padding(.horizontal, 4)
        .contentShape(Circle())
        .onTapGesture {
          let userViewModel: UserDetailViewModel = .init(userID: viewModel.userID, user: user)
          router.path.append(userViewModel)
        }

      VStack(alignment: .leading) {
        HStack {
          TweetNameView(name: user.name, userName: user.userName)

          if user.verified! {
            Image.verifiedMark
          }

          Spacer()

          let isReply = viewModel.tweet.referencedTweets.contains(where: { $0.type == .repliedTo })
          if isReply {
            Image(systemName: "bubble.left.and.bubble.right")
          }

          TweetDateView(date: viewModel.showDate)

          if viewModel.tweetText.isEdited {
            Image(systemName: "pencil.line")
          }
        }

        LinkableText(tweet: viewModel.tweetText, userID: viewModel.userID)
          .lineLimit(nil)
          .fixedSize(horizontal: false, vertical: true)

        if let poll = viewModel.poll {
          PollView(poll: poll)
        }

        // TODO Viewのサイズを固定しないとスクロール時に描画が崩れる
        if !viewModel.medias.isEmpty {
          MediasView(medias: viewModel.medias)
            .padding(.vertical)
        }

        if let placeName = viewModel.place?.name {
          Text(placeName)
            .onTapGesture {
              var components: URLComponents = .init(string: "http://maps.apple.com/")!
              components.queryItems = [.init(name: "q", value: placeName)]
              openURL(components.url!)
            }
            .foregroundColor(.secondary)
        }

        if let quoted = viewModel.quoted {
          QuotedTweetCellView(userID: viewModel.userID, tweet: quoted.tweet, user: quoted.user)
            .contentShape(Rectangle())
            .onTapGesture {
              let tweetDetailView: TweetDetailViewModel = .init(
                cellViewModel: TweetCellViewModel(
                  userID: viewModel.userID,
                  tweet: quoted.tweet,
                  author: quoted.user
                )
              )
              router.path.append(tweetDetailView)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .overlay(RoundedRectangle(cornerRadius: 20).stroke(.secondary, lineWidth: 2))
        }

        // TODO Viewのサイズを固定しないとスクロール時に描画が崩れる
        if viewModel.tweet.attachments?.mediaKeys.isEmpty != false,
          let urlModel = viewModel.tweet.entity?.urls.first,
          let url = urlModel.expandedURL.map { URL(string: $0) } ?? urlModel.url
        {
          OGPCardView(viewModel: .init(url: url))
        }
        
        if isRetweeted {
          HStack {
            Image(systemName: "repeat")
              .font(.system(size: 15, weight: .medium, design: .default))
            ProfileImageView(url: viewModel.author.profileImageURL!)
              .frame(width: 20, height: 20)
            Text(viewModel.author.name)
              .lineLimit(1)
          }
        }
      }
    }
    .alert(errorHandle: $viewModel.errorHandle)
  }
}
