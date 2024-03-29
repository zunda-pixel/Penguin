//
//  LikeButton.swift
//

import Sweet
import SwiftUI

struct LikeButton: View {
  @Binding var errorHandle: ErrorHandle?

  let userID: String
  let tweetID: String

  func action() async {
    do {
      try await Sweet(userID: userID).like(userID: userID, tweetID: tweetID)
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
      Label("Like", systemImage: "heart")
    }
  }
}

struct UnLikeButton: View {
  @Binding var errorHandle: ErrorHandle?

  let userID: String
  let tweetID: String

  func action() async {
    do {
      try await Sweet(userID: userID).unLike(userID: userID, tweetID: tweetID)
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
      Label("UnLike", systemImage: "heart.slash")
    }
  }
}
