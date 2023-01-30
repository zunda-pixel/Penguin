//
//  UserProfileViewModel.swift
//

import Foundation
import MapKit
import Sweet

@MainActor
final class UserProfileViewModel: ObservableObject {
  let user: Sweet.UserModel
  @Published var region: MKLocalSearch.Response?

  init(user: Sweet.UserModel) {
    self.user = user
  }

  func fetchRegion(location: String) async {
    let request = MKLocalSearch.Request()
    request.naturalLanguageQuery = location
    let search = MKLocalSearch(request: request)

    do {
      let response = try await search.start()
      self.region = response
    } catch {
      print(error)
    }
  }
}
