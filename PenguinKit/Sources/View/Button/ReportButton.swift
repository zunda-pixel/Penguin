//
//  ReportButton.swift
//

import SwiftUI

struct ReportButton: View {
  let userName: String
  let tweetID: String
  
  var tweetURL: URL {
    URL(string: "https://twitter.com/\(userName)/status/\(tweetID)")!
  }
  
  @Environment(\.openURL) var openURL
  
  var body: some View {
    Button {
      openURL(tweetURL)
    } label: {
      Label("Report", systemImage: "flag")
    }
  }
}
