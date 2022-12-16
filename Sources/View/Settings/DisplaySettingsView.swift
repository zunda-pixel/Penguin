//
// DisplaySettingsView.swift
//

import SwiftUI
import Sweet

struct DisplaySettingsView: View {
  @Binding var settings: Settings
  
  var body: some View {
    List {
      Group {
        let viewModel = TweetCellViewModel(
          userID: "",
          tweet: .twitterTweet,
          author: .twitterUser
        )
        
        TweetCellView(viewModel: viewModel)
          .highPriorityGesture(TapGesture()) // override Empty TapGesture to disable tap
        
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
      .foregroundStyle(colorType.colorSet.tintColor, colorScheme == .dark ? colorType.colorSet.darkPrimaryColor : colorType.colorSet.lightPrimaryColor)
  }
}

private extension Sweet.TweetModel {
  static let twitterTweet: Self = .init(
    id: "",
    text: "Hello #twitter @twitter $twitter https://twitter.com",
    createdAt: .now.addingTimeInterval(-23_456),
    entity: .init(
      urls: [
        .init(
          start: 0,
          end: 0,
          url: .init(string: "https://twitter.com")!,
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

private extension Sweet.UserModel {
  static let twitterUser: Self = .init(
    id: "",
    name: "Twitter",
    userName: "Twitter",
    verified: true,
    profileImageURL: .init(
      string: "https://pbs.twimg.com/profile_images/1488548719062654976/u6qfBBkF.jpg"
    )!
  )
}
