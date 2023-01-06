//
//  Sweet+Extension.swift
//

import Foundation
import Sweet

extension Sweet {
  private static func updateUserBearerToken(userID: String) async throws {
    let refreshToken = Secure.getRefreshToken(userID: userID)
    let response = try await Sweet.OAuth2().refreshUserBearerToken(with: refreshToken)

    let expireDate = Date.now.addingTimeInterval(TimeInterval(response.expiredSeconds))

    Secure.setRefreshToken(userID: userID, refreshToken: response.refreshToken!)
    Secure.setUserBearerToken(userID: userID, newUserBearerToken: response.bearerToken)
    Secure.setExpireDate(userID: userID, expireDate: expireDate)
  }

  init(userID: String) async throws {
    let expireDate = Secure.getExpireDate(userID: userID)

    if expireDate < Date.now {
      try await Sweet.updateUserBearerToken(userID: userID)
    }

    let userBearerToken = Secure.getUserBearerToken(userID: userID)

    let token: Sweet.AuthorizationType = .oAuth2user(token: userBearerToken)

    self.init(token: token, config: .default)
    
    self.tweetFields = Sweet.TweetField.allCases.filter {
      $0 != .organicMetrics && $0 != .promotedMetrics && $0 != .privateMetrics && $0 != .contextAnnotations && $0 != .withheld
    }
    self.mediaFields = Sweet.MediaField.allCases.filter {
      $0 != .organicMetrics && $0 != .promotedMetrics && $0 != .privateMetrics
    }
  }
}

extension Sweet.OAuth2 {
  init() {
    self.init(clientID: Env.clientKey, clientSecret: Env.clientSecretKey)
  }
}
