//
//  NewListViewModel.swift
//

import Foundation
import Sweet

protocol NewListDelegate {
  func didCreateList(list: Sweet.ListModel)
}

class NewListViewModel: ObservableObject {
  @Published var name: String
  @Published var description: String
  @Published var isPrivate: Bool

  let userID: String
  let delegate: NewListDelegate

  @Published var errorHandle: ErrorHandle?

  init(userID: String, delegate: NewListDelegate) {
    self.userID = userID
    self.delegate = delegate

    self.name = ""
    self.description = ""
    self.isPrivate = false
  }

  var disableCreateList: Bool {
    name.isEmpty
  }

  func createList() async throws {
    let newList = try await Sweet(userID: userID).createList(
      name: name,
      description: description,
      isPrivate: isPrivate
    )
    let response = try await Sweet(userID: userID).list(listID: newList.id)
    delegate.didCreateList(list: response.list)
  }
}
