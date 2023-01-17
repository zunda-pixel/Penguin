//
//  OnlineUserDetailNavigationView.swift
//

import SwiftUI

struct OnlineNavigationView: View {
  let userID: String
  let schemeItem: SchemeItem
  @StateObject var router = NavigationPathRouter()
  @Environment(\.dismiss) var dismiss

  @ViewBuilder
  @MainActor
  var content: some View {
    switch schemeItem {
    case .userID(let id):
      OnlineUserDetailView(viewModel: .init(userID: userID, targetUserID: id))
    case .screenID(let id):
      OnlineUserDetailView(viewModel: .init(userID: userID, targetScreenID: id))
    case .tweetID(let id):
      OnlineTweetDetailView(viewModel: .init(userID: userID, tweetID: id))
    }
  }

  var body: some View {
    NavigationStack(path: $router.path) {
      content
        .navigationBarAttribute()
        .navigationDestination()
        .toolbar {
          ToolbarItem(placement: .navigationBarLeading) {
            Button {
              dismiss()
            } label: {
              Label("Back", systemImage: "xmark.circle")
            }
          }
        }
    }
    .environmentObject(router)
  }
}

enum SchemeItem: Identifiable {
  case userID(String)
  case screenID(String)
  case tweetID(String)

  var id: String {
    switch self {
    case .screenID(let id): return id
    case .userID(let id): return id
    case .tweetID(let id): return id
    }
  }

  static func from(url: URL) -> SchemeItem? {
    if let userID = url.queryItems.first(where: { $0.name == "userID" })?.value {
      return .userID(userID)
    }

    if let screenID = url.queryItems.first(where: { $0.name == "screenID" })?.value {
      return .screenID(screenID)
    }

    if let tweetID = url.queryItems.first(where: { $0.name == "tweetID" })?.value {
      return .tweetID(tweetID)
    }

    return nil
  }
}
