//
//  BookmarkButton.swift
//

import Sweet
import SwiftUI

struct BookmarkButton: View {
  @Binding var errorHandle: ErrorHandle?

  let userID: String
  let tweetID: String

  func action() async {
    do {
      try await Sweet(userID: userID).addBookmark(userID: userID, tweetID: tweetID)
    } catch {
      let errorHandle = ErrorHandle(error: error)
      errorHandle.log()
      self.errorHandle = errorHandle
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

struct UnBookmarkButton: View {
  @Binding var errorHandle: ErrorHandle?

  let userID: String
  let tweetID: String

  func action() async {
    do {
      try await Sweet(userID: userID).deleteBookmark(userID: userID, tweetID: tweetID)
    } catch {
      let errorHandle = ErrorHandle(error: error)
      errorHandle.log()
      self.errorHandle = errorHandle
    }
  }

  var body: some View {
    Button(role: .destructive) {
      Task {
        await action()
      }
    } label: {
      Label("Delete Bookmark", systemImage: "bookmark.slash")
    }
  }
}
