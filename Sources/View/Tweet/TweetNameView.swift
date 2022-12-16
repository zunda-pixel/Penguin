//
// TweetNameView.swift
//

import SwiftUI

struct TweetNameView: View {
  let name: String
  let userName: String

  @Environment(\.settings) var settings

  var body: some View {
    Group {
      switch settings.userNameDisplayMode {
      case .all:
        (Text(name).bold() + Text(" @\(userName)").foregroundColor(.secondary))
      case .onlyDisplayName:
        Text(name).bold()
      case .onlyUserName:
        Text("@\(userName)").bold()
      }
    }
    .lineLimit(1)
  }
}

struct TweetNameView_Previews: PreviewProvider {
  static var previews: some View {
    TweetNameView(name: "twiter", userName: "twitter")
  }
}
