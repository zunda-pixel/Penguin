//
// DisplaySettingsView.swift
//

import Sweet
import SwiftUI

struct DisplaySettingsView: View {
  @Binding var settings: Settings

  var body: some View {
    List {
      Group {
        let viewModel = TweetCellViewModel(
          userID: "",
          tweet: .twitterTweet,
          author: .twitterUser,
          retweet: nil,
          quoted: nil,
          medias: [],
          polls: [],
          places: []
        )

        TweetCellView(viewModel: viewModel)
          .highPriorityGesture(TapGesture())  // override Empty TapGesture to disable tap

        Section("Color") {
          Picker(selection: $settings.colorType) {
            ForEach(ColorType.allCases) { colorType in
              ColorCell(colorType: colorType)
                .tag(colorType)
            }
          } label: {
            Text("Color")
          }
        }

        Section("Name") {
          Picker("Name", selection: $settings.userNameDisplayMode) {
            ForEach(DisplayUserNameMode.allCases) { mode in
              Text(mode.rawValue)
                .tag(mode)
            }
          }
        }

        Section("Date Format") {
          Picker("Date Format", selection: $settings.dateFormat) {
            ForEach(DateFormatMode.allCases) { mode in
              Text(mode.rawValue)
                .tag(mode)
            }
          }
        }
      }
    }
  }
}

struct ColorCell: View {
  @Environment(\.colorScheme) var colorScheme

  let colorType: ColorType

  var body: some View {
    Label(colorType.rawValue, systemImage: "cloud.moon.fill")
      .symbolRenderingMode(.palette)
      .foregroundStyle(
        colorType.colorSet.tintColor,
        colorScheme == .dark
          ? colorType.colorSet.darkPrimaryColor : colorType.colorSet.lightPrimaryColor)
  }
}

extension Sweet.TweetModel {
  fileprivate static let twitterTweet: Self = .init(
    id: "",
    text: "Hello #twitter @twitter $twitter https://twitter.com",
    createdAt: .now.addingTimeInterval(-23_456),
    entity: .init(
      urls: [
        .init(
          url: .init(string: "https://twitter.com")!,
          start: 0,
          end: 0,
          expandedURL: "",
          displayURL: ""
        )
      ],
      hashtags: [.init(start: 0, end: 0, tag: "twitter")],
      mentions: [.init(start: 0, end: 0, userName: "twitter")],
      cashtags: [.init(start: 0, end: 0, tag: "twitter")]
    )
  )
}

extension Sweet.UserModel {
  fileprivate static let twitterUser: Self = .init(
    id: "",
    name: "Twitter",
    userName: "Twitter",
    verified: true,
    profileImageURL: .init(
      string: "https://pbs.twimg.com/profile_images/1488548719062654976/u6qfBBkF.jpg"
    )!
  )
}

struct DisplaySettingsView_Preview: PreviewProvider {
  static var previews: some View {
    DisplaySettingsView(settings: .constant(.init()))
  }
}
