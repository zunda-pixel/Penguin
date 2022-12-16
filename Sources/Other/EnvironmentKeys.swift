//
// EnvironmentKeys.swift
//

import SwiftUI
import Sweet

struct SettingsKey: EnvironmentKey {
  static let defaultValue: Settings = .init()
}

struct LoginUsersKey: EnvironmentKey {
  static let defaultValue: [Sweet.UserModel] = []
}

extension EnvironmentValues {
  var settings: Settings {
    get { self[SettingsKey.self] }
    set { self[SettingsKey.self] = newValue }
  }
  
  var loginUsers: [Sweet.UserModel] {
    get { self[LoginUsersKey.self] }
    set { self[LoginUsersKey.self] = newValue }
  }
}
