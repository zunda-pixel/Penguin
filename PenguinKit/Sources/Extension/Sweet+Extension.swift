//
//  Sweet+Extension.swift
//

import Foundation
import Sweet

extension Sweet {
  private static func updateUserBearerToken(userID: String, tryCount: Int = 0) async throws {
    guard tryCount < 2 else { return }

    guard let refreshToken = Secure.getAuthorization(userID: userID)?.refreshToken else { throw LocalAuthorizationError.noRefreshToken }
    
    let response: Sweet.OAuth2Model

    do {
      response = try await Sweet.OAuth2().refreshUserBearerToken(with: refreshToken)
    } catch Sweet.AuthorizationError.invalidRequest {
      try await updateUserBearerToken(userID: userID, tryCount: tryCount + 1)
      return
    }

    let expireDate = Date.now.addingTimeInterval(TimeInterval(response.expiredSeconds))

    let authorization: AuthorizationModel = .init(
      bearerToken: response.bearerToken,
      refreshToken: response.refreshToken!,
      expiredDate: expireDate
    )
    
    Secure.setAuthorization(userID: userID, authorization: authorization)
  }

  public init(userID: String) async throws {
    guard let expireDate = Secure.getAuthorization(userID: userID)?.expiredDate else { throw LocalAuthorizationError.noExpireDate }

    if expireDate < Date.now {
      try await Sweet.updateUserBearerToken(userID: userID)
    }

    guard let userBearerToken = Secure.getAuthorization(userID: userID)?.bearerToken else { throw LocalAuthorizationError.noBearerToken }

    let token: Sweet.AuthorizationType = .oAuth2user(token: userBearerToken)

    self.init(token: token, config: .default)

    self.tweetFields = Sweet.TweetField.allCases.filter {
      $0 != .organicMetrics && $0 != .promotedMetrics && $0 != .privateMetrics
        && $0 != .contextAnnotations && $0 != .withheld
    }
    
    self.mediaFields = Sweet.MediaField.allCases.filter {
      $0 != .organicMetrics && $0 != .promotedMetrics && $0 != .privateMetrics
    }
  }
}

extension Sweet.OAuth2 {
  init() {
    if let customClient = Secure.customClient {
      self.init(clientID: customClient.id, clientSecret: customClient.secretKey)
    } else {
      self.init(clientID: Env.clientKey, clientSecret: Env.clientSecretKey)
    }
  }
}

extension Sweet {
  func tweets(ids: some Collection<String>) async throws -> [TweetsResponse] {
    var responses: [TweetsResponse] = []

    try await withThrowingTaskGroup(of: Sweet.TweetsResponse.self) { group in
      for tweetIDs in ids.chunks(ofCount: 100) {
        group.addTask {
          try await self.tweets(by: Array(tweetIDs))
        }
      }

      for try await response in group {
        responses.append(response)
      }
    }

    return responses
  }
}
