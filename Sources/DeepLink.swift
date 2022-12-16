//
//  DeepLink.swift
//

import CoreData
import Foundation
import Sweet

protocol DeepLinkDelegate {
  func setUser(user: Sweet.UserModel)
  func addUser(user: Sweet.UserModel) throws
}

struct DeepLink {
  let delegate: DeepLinkDelegate
  let context: NSManagedObjectContext

  func doSomething(_ url: URL) async throws {
    let components = URLComponents(url: url, resolvingAgainstBaseURL: true)!

    guard let queryItems = components.queryItems,
      let savedState = Secure.state
    else { return }

    if let state = queryItems.first(where: { $0.name == "state" })?.value,
      let code = queryItems.first(where: { $0.name == "code" })?.value,
      state == savedState
    {
      try await saveOAuthData(code: code)
    }
  }

  private func getMyUser(userBearerToken: String) async throws -> Sweet.UserModel {
    let token: Sweet.AuthorizationType = .oAuth2user(token: userBearerToken)
    let sweet = Sweet(token: token, config: .default)
    let response = try await sweet.me()
    return response.user
  }

  private func saveOAuthData(code: String) async throws {
    guard let challenge = Secure.challenge else {
      return
    }

    let response = try await Sweet.OAuth2().getUserBearerToken(
      code: code,
      callBackURL: Secure.callBackURL,
      challenge: challenge
    )

    let user = try await getMyUser(userBearerToken: response.bearerToken)

    Secure.currentUser = user
    Secure.loginUsers.append(user)
    Secure.setUserBearerToken(userID: user.id, newUserBearerToken: response.bearerToken)
    Secure.setRefreshToken(userID: user.id, refreshToken: response.refreshToken!)

    var dateComponent = DateComponents()
    dateComponent.second = response.expiredSeconds

    let expireDate = Calendar.current.date(byAdding: dateComponent, to: .now)!
    Secure.setExpireDate(userID: user.id, expireDate: expireDate)

    try Secure.removeState()
    try Secure.removeChallenge()

    try delegate.addUser(user: user)
    delegate.setUser(user: user)
  }
}
