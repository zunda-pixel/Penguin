//
//  Secure.swift
//

import Foundation
import KeychainAccess
import Sweet

public struct Secure {
  private static let currentUserKey = "currentUser"
  private static let challengeKey = "challenge"
  private static let stateKey = "state"
  private static let loginUserIDsKey = "loginUserIDsKey"
  private static let settingKey = "settingKey"
  private static let customClientKey = "customClientKey"
  private static let authorizationKey = "authorizationKey"

  private static let dateFormatter = Sweet.TwitterDateFormatter()
  private static let userDefaults = UserDefaults(suiteName: Env.appGroups)!
  private static let keychain = Keychain(
    service: "main", accessGroup: "\(Env.teamID)\(Env.appGroups)")

  static func removeChallenge() throws {
    userDefaults.removeObject(forKey: challengeKey)
  }

  static func removeState() throws { userDefaults.removeObject(forKey: stateKey) }

  static var challenge: String? {
    get { userDefaults.string(forKey: challengeKey) }
    set { userDefaults.set(newValue, forKey: challengeKey) }
  }

  static var state: String? {
    get { userDefaults.string(forKey: stateKey) }
    set { userDefaults.set(newValue, forKey: stateKey) }
  }

  static func getAuthorization(userID: String) -> AuthorizationModel? {
    guard let data = try! keychain.getData(userID + authorizationKey) else { return nil }
    return try! JSONDecoder().decode(AuthorizationModel.self, from: data)
  }

  static func setAuthorization(userID: String, authorization: AuthorizationModel) {
    let data = try! JSONEncoder().encode(authorization)
    try! keychain.set(data, key: userID + authorizationKey)
  }

  public static var currentUser: Sweet.UserModel? {
    get {
      guard let data = userDefaults.data(forKey: currentUserKey) else { return nil }
      let user = try! JSONDecoder.twitter.decode(Sweet.UserModel.self, from: data)
      return user
    }
    set {
      guard let newValue else {
        userDefaults.removeObject(forKey: currentUserKey)
        return
      }

      let data = try! JSONEncoder.twitter.encode(newValue)
      userDefaults.set(data, forKey: currentUserKey)
    }
  }

  public static var loginUsers: [Sweet.UserModel] {
    get {
      guard let data = userDefaults.data(forKey: loginUserIDsKey) else { return [] }
      let users = try! JSONDecoder.twitter.decode([Sweet.UserModel].self, from: data)
      return users
    }
    set {
      let data = try! JSONEncoder.twitter.encode(Array(Set(newValue)))

      userDefaults.set(data, forKey: loginUserIDsKey)
    }
  }

  static func removeUserData(userID: String) {
    try! keychain.remove(userID + authorizationKey)

    loginUsers.removeAll { $0.id == userID }

    if userID == currentUser?.id {
      currentUser = loginUsers.first
    }
  }

  public static var settings: Settings {
    get {
      guard let data = userDefaults.data(forKey: settingKey) else {
        return Settings()
      }
      let settings = try! JSONDecoder().decode(Settings.self, from: data)
      return settings
    }
    set {
      let data = try! JSONEncoder().encode(newValue)
      userDefaults.set(data, forKey: settingKey)
    }
  }

  static var customClient: Client? {
    get {
      guard let data = try! keychain.getData(Secure.customClientKey) else {
        return nil
      }
      let client = try! JSONDecoder().decode(Client.self, from: data)
      return client
    }
    set {
      guard let newValue else {
        try! keychain.remove(Secure.customClientKey)
        return
      }
      let data = try! JSONEncoder().encode(newValue)
      try! keychain.set(data, key: Secure.customClientKey)
    }
  }
}
