//
//  UsersViewModel.swift
//

import Foundation
import Sweet

@MainActor protocol UsersViewProtocol: ObservableObject {
  var userID: String { get }
  var enableDelete: Bool { get }
  var users: [Sweet.UserModel] { get set }
  var errorHandle: ErrorHandle? { get set }
  var paginationToken: String? { get set }
  func fetchUsers(reset resetData: Bool) async
  func deleteUsers(ids: some Sequence<String>) async
}

extension UsersViewProtocol {
  func deleteUsers(ids: some Sequence<String>) async {
  }
}
