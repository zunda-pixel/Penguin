//
// TweetDateView.swift
//

import SwiftUI

struct TweetDateView: View {
  @Environment(\.settings) var settings

  let date: Date

  var body: some View {
    TimelineView(.periodic(from: .now, by: 1)) { context in
      switch settings.dateFormat {
      case .relative:
        Text((date..<context.date).formatted(.twitter))
      case .absolute:
        Text(date.formatted(.dateTime))
      }
    }
    .foregroundStyle(.secondary)
  }
}

struct TweetDateView_Previews: PreviewProvider {
  static var previews: some View {
    TweetDateView(date: .now.addingTimeInterval(123_456_789))
  }
}
