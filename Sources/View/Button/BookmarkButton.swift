//
//  BookmarkButton.swift
//

import SwiftUI
import Sweet

struct BookmarkButton: View {
  @Binding var errorHandle: ErrorHandle?
  
  let userID: String
  let tweetID: String
  
  func action() async {
    do {
      try await Sweet(userID: userID).addBookmark(userID: userID, tweetID: tweetID)
    } catch {
      errorHandle = ErrorHandle(error: error)
    }
  }
  
  var body: some View {
    Button {
      Task {
        await action()
      }
    } label: {
      Label("Bookmark", systemImage: "bookmark")
    }
  }
}
