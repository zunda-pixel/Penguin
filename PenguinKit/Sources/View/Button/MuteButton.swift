//
//  MuteButton.swift
//

import Sweet
import SwiftUI

struct MuteButton: View {
  let fromUserID: String
  let toUserID: String

  @Binding var errorHandle: ErrorHandle?

  func mute() async {
    do {
      try await Sweet(userID: fromUserID).muteUser(from: fromUserID, to: toUserID)
    } catch {
      let errorHandle = ErrorHandle(error: error)
      errorHandle.log()
      self.errorHandle = errorHandle
    }
  }

  var body: some View {
    Button {
      Task {
        await mute()
      }
    } label: {
      Label("Mute", systemImage: "speaker.slash")
    }
  }
}

struct UnMuteButton: View {
  let fromUserID: String
  let toUserID: String

  @Binding var errorHandle: ErrorHandle?

  func unMute() async {
    do {
      try await Sweet(userID: fromUserID).unMuteUser(from: fromUserID, to: toUserID)
    } catch {
      let errorHandle = ErrorHandle(error: error)
      errorHandle.log()
      self.errorHandle = errorHandle
    }
  }

  var body: some View {
    Button {
      Task {
        await unMute()
      }
    } label: {
      Label("UnMute", systemImage: "speaker")
    }
  }
}
