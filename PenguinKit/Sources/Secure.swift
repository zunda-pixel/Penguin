//
//  Secure.swift
//

import Foundation
import Sweet

public struct Secure {
  private static let currentUserKey = "currentUser"
  private static let expireDateKey = "expireDate"
  private static let refreshTokenKey = "refreshToken"
  private static let userBearerTokenKey = "userBearerToken"
  private static let challengeKey = "challenge"
  private static let stateKey = "state"
  private static let loginUserIDsKey = "loginUserIDs"
  private static let settingKey = "settingKey"

  private static let dateFormatter = Sweet.TwitterDateFormatter()
  private static let userDefaults = UserDefaults(suiteName: Env.appGroups)!

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

  static func getUserBearerToken(userID: String) -> String {
    userDefaults.string(forKey: userID + userBearerTokenKey)!
  }

  static func setUserBearerToken(userID: String, newUserBearerToken: String) {
    userDefaults.set(newUserBearerToken, forKey: userID + userBearerTokenKey)
  }

  static func getRefreshToken(userID: String) -> String {
    userDefaults.string(forKey: userID + refreshTokenKey)!
  }

  static func setRefreshToken(userID: String, refreshToken: String) {
    userDefaults.set(refreshToken, forKey: userID + refreshTokenKey)
  }

  static func getExpireDate(userID: String) -> Date {
    let expireDateString = userDefaults.string(forKey: userID + expireDateKey)!
    let expireDate = dateFormatter.date(from: expireDateString)!
    return expireDate
  }

  static func setExpireDate(userID: String, expireDate: Date) {
    let expireDateString = dateFormatter.string(from: expireDate)
    userDefaults.set(expireDateString, forKey: userID + expireDateKey)
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
    userDefaults.removeObject(forKey: userID + expireDateKey)
    userDefaults.removeObject(forKey: userID + userBearerTokenKey)
    userDefaults.removeObject(forKey: userID + refreshTokenKey)
    loginUsers.removeAll { $0.id == userID }

    if userID == currentUser?.id {
      currentUser = loginUsers.first
    }
  }

  static var settings: Settings {
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
}
