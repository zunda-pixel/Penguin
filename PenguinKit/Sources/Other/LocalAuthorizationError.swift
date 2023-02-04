//
//  LocalAuthorizationError.swift
//

import Foundation

enum LocalAuthorizationError: Error {
  case noExpireDate
  case noBearerToken
  case noRefreshToken
}
