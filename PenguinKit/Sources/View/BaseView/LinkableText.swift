//
// LinkableText.swift
//

import Sweet
import SwiftUI

struct LinkableText: View {
  struct LinkableModel {
    let mode: PrefixMode
    let query: String
  }

  enum PrefixMode: String {
    case hashtag = "#"
    case cashtag = "$"
    case mention = "@"
  }

  let tweet: Sweet.TweetModel
  let userID: String

  @EnvironmentObject var router: NavigationPathRouter

  static let baseURL = URL(string: "urlForLinkableText://")!

  func attributedURL(mode: PrefixMode, query: String) -> URL {
    var url = LinkableText.baseURL
    url.append(queryItems: [
      .init(name: "mode", value: mode.rawValue),
      .init(name: "query", value: query),
    ])
    return url
  }

  @MainActor func addURLs(text: AttributedString) -> AttributedString {
    var text = text

    for url in (tweet.entity?.urls ?? []) {
      for range in text.ranges(of: url.url.description) {
        text[range].link = url.url
      }
    }

    return text
  }

  @MainActor func addHashtags(text: AttributedString) -> AttributedString {
    var text = text

    for hashtag in (tweet.entity?.hashtags ?? []) {
      let hashtagValue = "#\(hashtag.tag)"
      for range in text.ranges(of: hashtagValue) {
        text[range].foregroundColor = .secondary
        text[range].link = attributedURL(mode: .hashtag, query: hashtagValue)
      }
    }

    return text
  }

  @MainActor func addMentions(text: AttributedString) -> AttributedString {
    var text = text

    for mention in (tweet.entity?.mentions ?? []) {
      let mentionValue = "@\(mention.userName)"

      for range in text.ranges(of: mentionValue, options: .caseInsensitive) {
        text[range].link = attributedURL(mode: .mention, query: mention.userName)
      }
    }

    return text
  }

  @MainActor func addCashtags(text: AttributedString) -> AttributedString {
    var text = text

    for cashtag in (tweet.entity?.cashtags ?? []) {
      let cashtagValue = "$\(cashtag.tag)"
      for range in text.ranges(of: cashtagValue, options: .widthInsensitive) {
        text[range].foregroundColor = .secondary
        text[range].link = attributedURL(mode: .cashtag, query: cashtagValue)
      }
    }

    return text
  }

  @MainActor var attributedString: AttributedString {
    let tweetText = tweet.tweetText
    let attributedString = AttributedString(tweetText)
    let textWithURL = addURLs(text: attributedString)
    let textWithHashtag = addHashtags(text: textWithURL)
    let textWithMention = addMentions(text: textWithHashtag)
    let textWithCashtag = addCashtags(text: textWithMention)
    return textWithCashtag
  }

  var body: some View {
    Text(attributedString)
      .environment(
        \.openURL,
        OpenURLAction { url in
          guard url.scheme == LinkableText.baseURL.scheme else { return .systemAction(url) }

          let modeRawValue = url.queryItems.first { $0.name == "mode" }?.value
          let query = url.queryItems.first { $0.name == "query" }?.value

          let mode: PrefixMode = .init(rawValue: modeRawValue!)!

          switch mode {
          case .cashtag:
            let viewModel: SearchTweetsViewModel = .init(
              userID: userID,
              query: query!,
              queryBuilder: .init()
            )
            router.path.append(viewModel)
          case .hashtag:
            let viewModel: SearchTweetsViewModel = .init(
              userID: userID,
              query: query!,
              queryBuilder: .init()
            )
            router.path.append(viewModel)
          case .mention:
            let viewModel: OnlineUserDetailViewModel = .init(
              userID: userID,
              targetScreenID: query!
            )
            router.path.append(viewModel)
          }

          return .handled
        }
      )
  }
}

struct LinkableText_Previews: PreviewProvider {
  @State static var path = NavigationPath()

  static var previews: some View {
    LinkableText(
      tweet: .init(
        id: "32",
        text: "#hashtag @mention $cash https://swift.org",
        entity: .init(
          urls: [
            .init(
              start: 0,
              end: 0,
              url: .init(string: "https://swift.org")!,
              expandedURL: "fsdf",
              displayURL: "fdsaf"
            )
          ],
          hashtags: [.init(start: 0, end: 0, tag: "hashtag")],
          mentions: [.init(start: 0, end: 0, userName: "mention")],
          cashtags: [.init(start: 0, end: 0, tag: "cash")]
        )
      ),
      userID: ""
    )
  }
}
