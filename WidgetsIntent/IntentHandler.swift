//
//  IntentHandler.swift
//

import Intents
import Sweet

class IntentHandler: INExtension {
}

extension IntentHandler: TweetConfigurationIntentHandling {
  func provideUserOptionsCollection(for intent: TweetConfigurationIntent, searchTerm: String?)
    async throws -> INObjectCollection<WidgetUser>
  {
    let users = try await users()

    guard let searchTerm else {
      return .init(items: users)
    }

    let filteredTitles = users.filter { $0.userName!.contains(searchTerm) }

    return .init(items: filteredTitles)
  }

  func users() async throws -> [WidgetUser] {
    let users = Secure.loginUsers

    if users.isEmpty {
      return []
    }

    let sweet = try await Sweet(userID: users.first!.id)

    let response = try await sweet.users(userIDs: users.map(\.id))

    return response.users.map {
      .init(user: $0)
    }
  }

  func defaultUser(for intent: TweetConfigurationIntent) -> WidgetUser? {
    guard let user = Secure.currentUser else { return nil }

    return .init(user: user)
  }
}

extension WidgetUser {
  public convenience init(user: Sweet.UserModel) {
    self.init(identifier: user.id, display: "@\(user.userName)")
    self.name = user.name
    self.userName = user.userName
    self.subtitleString = user.name
  }
}
