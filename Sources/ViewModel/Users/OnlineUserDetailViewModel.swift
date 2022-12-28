//
// OnlineUserDetailViewModel.swift
//

import Foundation
import Sweet

@MainActor class OnlineUserDetailViewModel: ObservableObject, Hashable {
  let userID: String
  let targetUserID: String?
  let targetScreenID: String?

  var loadingUser: Bool

  @Published var targetUser: Sweet.UserModel?
  @Published var errorHandle: ErrorHandle?


  init(userID: String, targetScreenID: String) {
    self.userID = userID
    
    // @twitter -> twitter
    self.targetScreenID = targetScreenID.replacingOccurrences(of: "@", with: "")
    self.targetUserID = nil
    
    self.loadingUser = false
  }
  
  init(userID: String, targetUserID: String) {
    self.userID = userID    
    self.targetScreenID = nil
    self.targetUserID = targetUserID
    
    self.loadingUser = false
  }

  func fetchUser() async {
    guard !loadingUser else { return }

    loadingUser.toggle()
    defer { loadingUser.toggle() }

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
    lhs.userID == rhs.userID &&
    (lhs.targetUserID == rhs.targetUserID || lhs.targetScreenID == rhs.targetScreenID)
  }

  nonisolated func hash(into hasher: inout Hasher) {
    hasher.combine(userID)
    hasher.combine(targetUserID)
    hasher.combine(targetScreenID)
  }
}
