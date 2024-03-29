//
// LinkableText.swift
//

import RegexBuilder
import Sweet
import SwiftUI

struct LinkableText<Value: Sequence<Sweet.URLModel>>: View {
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
  let excludeURLs: Value

  @EnvironmentObject var router: NavigationPathRouter

  let baseURL = URL(string: "urlForLinkableText://")!

  func attributedURL(mode: PrefixMode, query: String) -> URL {
    var url = baseURL
    url.append(queryItems: [
      .init(name: "mode", value: mode.rawValue),
      .init(name: "query", value: query),
    ])
    return url
  }

  func removeExcludeURLs(text: String) -> String {
    var text = text

    for url in excludeURLs {
      if let range = text.ranges(of: url.url.absoluteString).last {
        text.removeSubrange(range)
      }
    }

    return text
  }

  func removeUnnecessaryURLs(text: String) -> String {
    var text = text

    // https://twitter.com/userName/status/tweetID/photo/1
    let twitterPictureURLRegex = Regex {
      Anchor.startOfLine
      "pic.twitter.com/"
      Repeat(count: 10) {
        .whitespace.inverted
      }
      Anchor.endOfLine
    }

    for url in (tweet.entity?.urls ?? []) {
      let isMatch = url.displayURL?.isMatchWhole(of: twitterPictureURLRegex)

      guard isMatch == true else { continue }

      let regex = Regex {
        Anchor.startOfLine
        url.url.absoluteString
        Anchor.endOfLine
      }

      // remove line
      if let range = text.firstRange(of: regex) {
        let range = text.lineRange(for: range)
        text.removeSubrange(range)
        continue
      }

      // remove word
      if let range = text.firstRange(of: url.url.absoluteString) {
        text.removeSubrange(range)
        continue
      }
    }

    return text
  }

  @MainActor func addURLs(text: AttributedString) -> AttributedString {
    var text = text

    for url in (tweet.entity?.urls ?? []) {
      guard let range = text.range(of: url.url.absoluteString) else { continue }
      guard let displayURL = url.displayURL ?? url.expandedURL else {
        text[range].link = url.url
        continue
      }

      var attributedDisplayURL = AttributedString(displayURL)
      attributedDisplayURL.link = url.expandedURL.map { URL(string: $0) ?? url.url } ?? url.url
      text.replaceSubrange(range, with: attributedDisplayURL)
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
    let textWithoutExcludeURL = removeExcludeURLs(text: tweetText)
    let textWithoutUnnecessaryURL = removeUnnecessaryURLs(text: textWithoutExcludeURL)
    let attributedString = AttributedString(textWithoutUnnecessaryURL)
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
          guard url.scheme == baseURL.scheme else {
            return .systemAction(url)
          }

          let modeRawValue = url.queryItems.first { $0.name == "mode" }?.value
          let query = url.queryItems.first { $0.name == "query" }?.value

          let mode: PrefixMode = .init(rawValue: modeRawValue!)!

          switch mode {
          case .cashtag:
            let viewModel: SearchTweetsViewModel = .init(
              userID: userID,
              query: query!,
              queryBuilder: .init(excludeRetweet: true)
            )
            router.path.append(viewModel)
          case .hashtag:
            let viewModel: SearchTweetsViewModel = .init(
              userID: userID,
              query: query!,
              queryBuilder: .init(excludeRetweet: true)
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
              url: .init(string: "https://swift.org")!,
              start: 0,
              end: 0,
              expandedURL: "fsdf",
              displayURL: "fdsaf"
            )
          ],
          hashtags: [.init(start: 0, end: 0, tag: "hashtag")],
          mentions: [.init(start: 0, end: 0, userName: "mention")],
          cashtags: [.init(start: 0, end: 0, tag: "cash")]
        )
      ),
      userID: "",
      excludeURLs: []
    )
  }
}

extension BidirectionalCollection where Self.SubSequence == Substring {
  func isMatchWhole(of regex: some RegexComponent) -> Bool {
    self.wholeMatch(of: regex) != nil
  }
}
