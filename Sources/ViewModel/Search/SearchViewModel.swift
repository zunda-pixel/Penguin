//
//  SearchViewModel.swift
//

import Foundation

@MainActor final class SearchViewModel: ObservableObject {
  let userID: String

  @Published var query: String
  @Published var searchSettings: QueryBuilder

  init(userID: String, searchSettings: QueryBuilder) {
    self.userID = userID
    self.searchSettings = searchSettings
    self.query = ""
  }
}
