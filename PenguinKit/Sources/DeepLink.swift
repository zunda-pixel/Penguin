//
//  DeepLink.swift
//

import CoreData
import Foundation
import Sweet

protocol DeepLinkDelegate {
  func setUser(user: Sweet.UserModel)
  func addUser(user: Sweet.UserModel) async throws
}

struct DeepLink {
  let delegate: DeepLinkDelegate
  let context: NSManagedObjectContext

  func doSomething(_ url: URL) async throws {
    let components = URLComponents(url: url, resolvingAgainstBaseURL: true)!

    guard let queryItems = components.queryItems,
      let savedState = Secure.state
    else {
      return
    }

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
      callBackURL: Env.schemeURL,
      challenge: challenge
    )

    let user = try await getMyUser(userBearerToken: response.bearerToken)

    Secure.currentUser = user
    Secure.loginUsers.append(user)

    let expireDate = Date.now.addingTimeInterval(Double(response.expiredSeconds))

    let authorization: AuthorizationModel = .init(
      bearerToken: response.bearerToken,
      refreshToken: response.refreshToken!,
      expiredDate: expireDate
    )

    Secure.setAuthorization(userID: user.id, authorization: authorization)

    try Secure.removeState()
    try Secure.removeChallenge()

    try await delegate.addUser(user: user)
    delegate.setUser(user: user)
  }
}
