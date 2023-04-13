//
//  TweetView.swift
//

import Kingfisher
import Sweet
import SwiftUI

struct TweetCellView<ViewModel: TweetCellViewProtocol>: View {
  @Environment(\.openURL) private var openURL

  @EnvironmentObject var router: NavigationPathRouter

  let viewModel: ViewModel

  var body: some View {
    let isRetweeted = viewModel.tweet.referencedTweets.contains(where: { $0.type == .retweeted })

    let user = isRetweeted ? viewModel.retweet!.author : viewModel.author

    HStack(alignment: .top) {
      ProfileImageView(url: user.profileImageURL!)
        .frame(width: 50, height: 50)
        .padding(.trailing, 4)
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

        if let pollID = viewModel.tweetText.attachments?.pollID,
          let poll = viewModel.polls.first(where: { $0.id == pollID })
        {
          PollView(poll: poll)
            .frame(maxWidth: 400)
            .padding()
            .overlay {
              RoundedRectangle(cornerRadius: 13)
                .stroke(.secondary, lineWidth: 1)
            }
        }

        // TODO Viewのサイズを固定しないとスクロール時に描画が崩れる
        let medias =
          viewModel.tweetText.attachments?.mediaKeys.compactMap { id in
            viewModel.medias.first { $0.id == id }
          } ?? []
        if !medias.isEmpty {
          MediasView(medias: medias)
            .cornerRadius(15)
        }

        if let placeID = viewModel.tweetText.geo?.placeID,
          let place = viewModel.places.first(where: { $0.id == placeID })
        {
          Text(place.fullName)
            .onTapGesture {
              var components: URLComponents = .init(string: "https://maps.apple.com/")!
              components.queryItems = [.init(name: "q", value: place.fullName)]
              openURL(components.url!)
            }
            .foregroundColor(.secondary)
        }

        if let quoted = viewModel.quoted {
          QuotedTweetCellView(
            tweet: quoted.tweetContent.tweet,
            user: quoted.tweetContent.author
          )
          .frame(maxWidth: .infinity, alignment: .leading)
          .contentShape(Rectangle())
          .onTapGesture {
            let quotedTweetModel: QuotedTweetModel?

            if let quotedTweet = quoted.quoted {
              quotedTweetModel = QuotedTweetModel(
                tweetContent: .init(tweet: quotedTweet.tweet, author: quotedTweet.author),
                quoted: nil)
            } else {
              quotedTweetModel = nil
            }

            let tweets = [
              quoted.tweetContent.tweet,
              quotedTweetModel?.tweetContent.tweet,
              quotedTweetModel?.quoted?.tweet,
            ].compacted()

            // TODO できればcompactMapではなく、map(強制的アンラップ)で行いたい
            let medias = tweets.compactMap(\.attachments).flatMap(\.mediaKeys).compactMap { id in
              viewModel.medias.first { $0.id == id }
            }
            // TODO できればcompactMapではなく、map(強制的アンラップ)で行いたい
            let polls = tweets.compactMap(\.attachments).compactMap(\.pollID).compactMap { id in
              viewModel.polls.first { $0.id == id }!
            }
            // TODO できればcompactMapではなく、map(強制的アンラップ)で行いたい
            let places = tweets.compactMap(\.geo).compactMap(\.placeID).compactMap { id in
              viewModel.places.first { $0.id == id }!
            }

            let tweetDetailView: TweetDetailViewModel = .init(
              cellViewModel: TweetCellViewModel(
                userID: viewModel.userID,
                tweet: quoted.tweetContent.tweet,
                author: quoted.tweetContent.author,
                retweet: nil,
                quoted: quotedTweetModel,
                medias: medias,
                polls: polls,
                places: places
              )
            )
            router.path.append(tweetDetailView)
          }
          .padding(.horizontal, 10)
          .padding(.vertical, 5)
          .overlay(RoundedRectangle(cornerRadius: 20).stroke(.secondary, lineWidth: 2))
        }

        let urlModel = viewModel.tweet.entity?.urls.filter {
          // TODO statusがnilの場合がある
          // 対処しなくてもいい
          !$0.images.isEmpty && (200..<300).contains($0.status ?? 401)
        }.first

        // TODO Viewのサイズを固定しないとスクロール時に描画が崩れる
        if let urlModel = urlModel,
          viewModel.tweet.attachments?.mediaKeys.isEmpty != false
        {
          OGPCardView(urlModel: urlModel)
            .frame(maxWidth: 300, maxHeight: 300)
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
  }
}

struct TweetCellView_Previews: PreviewProvider {
  static var previews: some View {
    TweetCellView(viewModel: TweetCellViewModel.placeHolder)
  }
}
