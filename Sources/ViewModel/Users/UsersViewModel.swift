//
//  UsersViewModel.swift
//

import Foundation
import Sweet

@MainActor protocol UsersViewProtocol: ObservableObject {
  var userID: String { get }
  var users: [Sweet.UserModel] { get set }
  var errorHandle: ErrorHandle? { get set }
  var paginationToken: String? { get set }
  var loadingUser: Bool { get set }
  func fetchUsers(reset resetData: Bool) async
}
