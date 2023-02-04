//
//  AuthorizationModel.swift
//

import Foundation

struct AuthorizationModel: Codable {
  let bearerToken: String
  let refreshToken: String
  let expiredDate: Date
}
