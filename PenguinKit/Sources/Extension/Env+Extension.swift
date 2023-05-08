//
//  Env+Extension.swift
//

import Foundation

extension Env {
  static let teamID: String = Bundle.main.infoDictionary!["AppIdentifierPrefix"] as! String

  static let appGroups: String = "group.zunda.penguin"
  static let schemeURL: URL = .init(string: "penguin://")!
}
