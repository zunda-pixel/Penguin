//
// Env.swift
//

import Foundation

enum Env {
  static let clientKey: String = <#CLIENT_KEY#>
  static let clientSecretKey: String = <#CLIENT_SECRET_KEY#>
  
  static let teamID: String = Bundle.main.infoDictionary!["AppIdentifierPrefix"] as! String

  static let appGroups: String = "group.zunda.penguin"
  static let schemeURL: URL = .init(string: "penguin://")!
}
