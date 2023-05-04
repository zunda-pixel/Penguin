//
// OnlineUserDetailViewModel.swift
//

import Foundation
import Sweet

@MainActor final class OnlineUserDetailViewModel: ObservableObject, Hashable {
  let userID: String
  let targetUserID: String?
  let targetScreenID: String?

  @Published var targetUser: Sweet.UserModel?
  @Published var errorHandle: ErrorHandle?

  init(userID: String, targetScreenID: String) {
    self.userID = userID

    // @twitter -> twitter
    self.targetScreenID = targetScreenID.replacingOccurrences(of: "@", with: "")
    self.targetUserID = nil
  }

  init(userID: String, targetUserID: String) {
    self.userID = userID
    self.targetScreenID = nil
    self.targetUserID = targetUserID
  }

  func fetchUser() async {
    guard targetUser == nil else { return }

    do {
      if let targetScreenID {
        targetUser = try await Sweet(userID: userID).user(screenID: targetScreenID).user
      } else if let targetUserID {
        targetUser = try await Sweet(userID: userID).user(userID: targetUserID).user
      }
    } catch {
      let errorHandle = ErrorHandle(error: error)
      errorHandle.log()
      self.errorHandle = errorHandle
    }
  }

  nonisolated static func == (lhs: OnlineUserDetailViewModel, rhs: OnlineUserDetailViewModel)
    -> Bool
  {
    lhs.userID == rhs.userID
      && (lhs.targetUserID == rhs.targetUserID || lhs.targetScreenID == rhs.targetScreenID)
  }

  nonisolated func hash(into hasher: inout Hasher) {
    hasher.combine(userID)
    hasher.combine(targetUserID)
    hasher.combine(targetScreenID)
  }
}
