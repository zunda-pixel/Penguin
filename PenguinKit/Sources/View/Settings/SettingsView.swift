//
//  SettingsView.swift
//

import StoreKit
import Sweet
import SwiftUI
import LicenseView

struct SettingsView: View {
  @Environment(\.dismiss) var dimiss
  @Environment(\.requestReview) var requestReview

  @StateObject var router = NavigationPathRouter()

  @Binding var settings: Settings
  @Binding var currentUser: Sweet.UserModel?
  @Binding var loginUsers: [Sweet.UserModel]

  func logout(user: Sweet.UserModel) {
    Secure.removeUserData(userID: user.id)

    self.loginUsers = Secure.loginUsers
    self.currentUser = Secure.currentUser

    if self.currentUser == nil {
      dimiss()
    }
  }

  var body: some View {
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
            
            NavigationLink {
              IconSettingsView()
                .navigationTitle("App Icon")
            } label: {
              Label("App Icon", systemImage: "rectangle.grid.2x2")
            }
          }

          Section("ABOUT") {
#if DEBUG

            NavigationLink {
              VStack {
                if let userID = currentUser?.id {
                  Text(Secure.getUserBearerToken(userID: userID))
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
      .navigationBarTitleDisplayMode(.large)
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
