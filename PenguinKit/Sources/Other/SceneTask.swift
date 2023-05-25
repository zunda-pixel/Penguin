//
//  SceneTask.swift
//

import SwiftUI

private struct SceneTask: ViewModifier {
  @Environment(\.scenePhase) var scenePhase
  @State var launchBackground = true
  let action: () async -> Void

  func body(content: Content) -> some View {
    content
      .task(id: scenePhase) {
        guard scenePhase != .background else {
          launchBackground = true
          return
        }
        guard launchBackground, scenePhase == .active else { return }
        launchBackground = false
        await action()
      }
  }
}

extension View {
  func sceneTask(action: @escaping () async -> Void) -> some View {
    return self.modifier(SceneTask(action: action))
  }
}
