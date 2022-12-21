//
//  LoginView.swift
//

import CoreData
import Sweet
import SwiftUI
import os
import BetterSafariView

struct LoginView<Label: View>: View {
  @Environment(\.openURL) var openURL
  @Environment(\.managedObjectContext) var context
  @Binding var currentUser: Sweet.UserModel?
  @Binding var loginUsers: [Sweet.UserModel]
  @State var errorHandle: ErrorHandle?

  @State var authorizeURL: URL?
  let label: Label

  init(
    currentUser: Binding<Sweet.UserModel?>,
    loginUsers: Binding<[Sweet.UserModel]>,
    @ViewBuilder label: () -> Label
  ) {
    self._currentUser = currentUser
    self._loginUsers = loginUsers
    self.label = label()
  }

  func getRandomString() -> String {
    let challenge = SecurityRandom.secureRandomBytes(count: 10)
    return challenge.reduce(into: "") { $0 = $0 + "\($1)" }
  }

  func getAuthorizeURL() -> URL {
    let challenge = getRandomString()
    Secure.challenge = challenge

    let state = getRandomString()
    Secure.state = state

    let url = Sweet.OAuth2().getAuthorizeURL(
      scopes: Sweet.AccessScope.allCases,
      callBackURL: Secure.callBackURL,
      challenge: challenge,
      state: state
    )

    return url
  }

  func doSomething(url: URL) async {
    let deepLink = DeepLink(delegate: self, context: context)

    do {
      try await deepLink.doSomething(url)
    } catch {
      errorHandle = ErrorHandle(error: error)
    }
  }

  var body: some View {
    Button {
      authorizeURL = getAuthorizeURL()
    } label: {
      label
    }
    .safariView(item: $authorizeURL) { url in
      SafariView(url: url)
    }
    .alert(errorHandle: $errorHandle)
    .onOpenURL { url in
      Task {
        await doSomething(url: url)
      }
    }
  }
}

extension LoginView: DeepLinkDelegate {
  func setUser(user: Sweet.UserModel) {
    self.currentUser = user
    self.loginUsers = Secure.loginUsers
  }

  func addUser(user: Sweet.UserModel) throws {
    let fetchRequest = NSFetchRequest<User>()
    fetchRequest.entity = User.entity()
    fetchRequest.sortDescriptors = []

    let users = try context.fetch(fetchRequest)

    if let foundUser = users.first(where: { $0.id == user.id }) {
      try foundUser.setUserModel(user)
    } else {
      let newUser = User(context: context)
      try newUser.setUserModel(user)
    }

    try context.save()
  }
}
