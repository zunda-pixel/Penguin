//
//  SettingsView.swift
//

import LicenseView
import StoreKit
import Sweet
import SwiftUI

public struct SettingsView: View {
  @Environment(\.dismiss) var dimiss
  @Environment(\.requestReview) var requestReview

  @StateObject var router = NavigationPathRouter()

  @Binding var settings: Settings
  @Binding var currentUser: Sweet.UserModel?
  @Binding var loginUsers: [Sweet.UserModel]

  public init(
    settings: Binding<Settings>, currentUser: Binding<Sweet.UserModel?>,
    loginUsers: Binding<[Sweet.UserModel]>
  ) {
    self._settings = settings
    self._currentUser = currentUser
    self._loginUsers = loginUsers
  }

  func logout(user: Sweet.UserModel) {
    Secure.removeUserData(userID: user.id)

    self.loginUsers = Secure.loginUsers
    self.currentUser = Secure.currentUser

    if self.currentUser == nil {
      dimiss()
    }
  }

  public var body: some View {
    NavigationStack(path: $router.path) {
      List {
        Group {
          Section("Account") {
            ForEach(loginUsers) { user in
              let viewModel = AccountDetailViewModel(userID: currentUser!.id, user: user)

              NavigationLink(value: viewModel) {
                Label {
                  Text(user.name) + Text("@\(user.userName)").foregroundColor(.secondary)
                } icon: {
                  ProfileImageView(url: user.profileImageURL!)
                    .frame(width: 30, height: 30)
                }
              }
              .swipeActions(edge: .trailing) {
                Button("Logout", role: .destructive) {
                  logout(user: user)
                }
              }
            }

            LoginView(currentUser: $currentUser, loginUsers: $loginUsers) {
              Label("Add Account", systemImage: "plus.app")
            }
          }

          Section("General") {
            NavigationLink {
              DisplaySettingsView(settings: $settings)
            } label: {
              Label("Display", systemImage: "iphone")
            }

            NavigationLink {
              TabSettingsView(settings: $settings)
            } label: {
              Label("Tab", systemImage: "dock.rectangle")
            }

            #if DEBUG
              NavigationLink {
                Text("Hello")
              } label: {
                Label("Sound", systemImage: "speaker")
                  .symbolVariant(.circle)
              }

              NavigationLink {
                Text("Hello")
              } label: {
                Label("Browser", systemImage: "safari")
              }
            #endif

            #if !os(macOS)
              NavigationLink {
                IconSettingsView()
                  .navigationTitle("App Icon")
              } label: {
                Label("App Icon", systemImage: "rectangle.grid.2x2")
              }
            #endif
          }

          Section("ABOUT") {
            #if DEBUG

              NavigationLink {
                VStack {
                  if let userID = currentUser?.id,
                     let bearerToken = Secure.getAuthorization(userID: userID)?.bearerToken {
                    Text(bearerToken)
                      .textSelection(.enabled)
                  }
                  Text("Manage Subscription")
                }
              } label: {
                Label("Manage Subscription", systemImage: "person")
              }
              NavigationLink {
                Text("Hello")
              } label: {
                Label("Sync Status", systemImage: "person")
              }
              NavigationLink {
                Text("Hello")
              } label: {
                Label("Support", systemImage: "person")
              }
              NavigationLink {
                Text("Hello")
              } label: {
                Label("@zunda", systemImage: "person")
              }
            #endif

            NavigationLink {
              LicenseView()
                .navigationTitle("License")
            } label: {
              Label("License", systemImage: "lock.shield")
            }
            
            NavigationLink {
              CustomClientSettingsView(
                currentUser: $currentUser,
                loginUsers: $loginUsers
              )
                .navigationTitle("Custom Client")
            } label: {
              Label("Custom Client", systemImage: "key.horizontal")
            }

            Button {
              requestReview()
            } label: {
              Label("Review in App Store", systemImage: "star")
            }
          }
        }
      }
      .onChange(of: settings) { newValue in
        Secure.settings = newValue
      }
      .navigationTitle("Settings")
      .navigationBarTitleDisplayModeIfAvailable(.large)
      .navigationDestination()
    }
    .environmentObject(router)
  }
}

struct SettingsView_Preview: PreviewProvider {
  struct Preview: View {
    @State var settings = Settings()
    @State var currentUser: Sweet.UserModel?
    @State var loginUsers: [Sweet.UserModel] = []

    var body: some View {
      SettingsView(settings: $settings, currentUser: $currentUser, loginUsers: $loginUsers)
    }
  }

  static var previews: some View {
    Preview()
  }
}
