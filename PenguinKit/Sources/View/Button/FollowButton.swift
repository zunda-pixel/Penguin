//
//  FollowButton.swift
//

import Sweet
import SwiftUI

struct FollowButton: View {
  let fromUserID: String
  let toUserID: String

  @Binding var errorHandle: ErrorHandle?

  func follow() async {
    do {
      _ = try await Sweet(userID: fromUserID).follow(from: fromUserID, to: toUserID)
    } catch {
      let errorHandle = ErrorHandle(error: error)
      errorHandle.log()
      self.errorHandle = errorHandle
    }
  }

  var body: some View {
    Button {
      Task {
        await follow()
      }
    } label: {
      Label("Follow", systemImage: "person.fill.checkmark")
    }
  }
}

struct UnFollowButton: View {
  let fromUserID: String
  let toUserID: String

  @Binding var errorHandle: ErrorHandle?

  func unFollow() async {
    do {
      _ = try await Sweet(userID: fromUserID).unFollow(from: fromUserID, to: toUserID)
    } catch {
      let errorHandle = ErrorHandle(error: error)
      errorHandle.log()
      self.errorHandle = errorHandle
    }
  }

  var body: some View {
    Button(role: .destructive) {
      Task {
        await unFollow()
      }
    } label: {
      Label("UnFollow", systemImage: "person.fill.xmark")
    }
  }
}
