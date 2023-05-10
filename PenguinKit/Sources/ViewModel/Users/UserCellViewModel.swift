//
//  UserCellViewModel.swift
//

import Foundation
import Sweet

final class UserCellViewModel: ObservableObject {
  let ownerID: String
  let user: Sweet.UserModel

  @Published var errorHandle: ErrorHandle?

  init(ownerID: String, user: Sweet.UserModel) {
    self.ownerID = ownerID
    self.user = user
  }

  func follow() async {
    do {
      let _ = try await Sweet(userID: ownerID).follow(from: ownerID, to: user.id)
    } catch {
      let errorHandle = ErrorHandle(error: error)
      errorHandle.log()
      self.errorHandle = errorHandle
    }
  }
}
