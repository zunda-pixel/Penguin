//
//  BlockButton.swift
//

import Sweet
import SwiftUI

struct BlockButton: View {
  let fromUserID: String
  let toUserID: String

  @Binding var errorHandle: ErrorHandle?

  func block() async {
    do {
      try await Sweet(userID: fromUserID).blockUser(from: fromUserID, to: toUserID)
    } catch {
      let errorHandle = ErrorHandle(error: error)
      errorHandle.log()
      self.errorHandle = errorHandle
    }
  }

  var body: some View {
    Button(role: .destructive) {
      Task {
        await block()
      }
    } label: {
      Label("Block", systemImage: "xmark.shield")
    }
  }
}

struct UnBlockButton: View {
  let fromUserID: String
  let toUserID: String

  @Binding var errorHandle: ErrorHandle?

  func unBlock() async {
    do {
      try await Sweet(userID: fromUserID).unBlockUser(from: fromUserID, to: toUserID)
    } catch {
      let errorHandle = ErrorHandle(error: error)
      errorHandle.log()
      self.errorHandle = errorHandle
    }
  }

  var body: some View {
    Button {
      Task {
        await unBlock()
      }
    } label: {
      Label("UnBlock", systemImage: "checkmark.shield")
    }
  }
}
