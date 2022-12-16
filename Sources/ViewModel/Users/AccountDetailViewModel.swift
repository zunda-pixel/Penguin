//
//  AccountDetailViewModel.swift
//

import Foundation
import Sweet

final class AccountDetailViewModel: ObservableObject, Hashable {
  let userID: String
  let user: Sweet.UserModel

  init(userID: String, user: Sweet.UserModel) {
    self.userID = userID
    self.user = user
  }

  func hash(into hasher: inout Hasher) {
    hasher.combine(userID)
    hasher.combine(user)
  }

  static func == (lhs: AccountDetailViewModel, rhs: AccountDetailViewModel) -> Bool {
    lhs.userID == rhs.userID && lhs.user == rhs.user
  }
}
