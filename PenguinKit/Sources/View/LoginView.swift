//
//  LoginView.swift
//

import BetterSafariView
import CoreData
import Sweet
import SwiftUI

struct LoginView<Label: View>: View {
  let label: Label

  @State var errorHandle: ErrorHandle?
  @State var authorizeURL: URL?

  @Environment(\.managedObjectContext) var context
  @Environment(\.dismiss) var dismiss

  #if os(macOS)
    @Environment(\.openURL) var openURL
  #endif

  @Binding var currentUser: Sweet.UserModel?
  @Binding var loginUsers: [Sweet.UserModel]

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
      callBackURL: Env.schemeURL,
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
      let errorHandle = ErrorHandle(error: error)
      errorHandle.log()
      self.errorHandle = errorHandle
    }
  }

  var body: some View {
    Button {
      authorizeURL = getAuthorizeURL()
      #if os(macOS)
        openURL(authorizeURL!)
      #endif
    } label: {
      label
    }
    #if !os(macOS)
      .sheet(item: $authorizeURL) { url in
        SafariView(url: url)
      }
    #endif
    .alert(errorHandle: $errorHandle)
    .onOpenURL { url in
      Task {
        await doSomething(url: url)
        dismiss()
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
