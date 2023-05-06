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

  #if os(macOS)
    @State var selectedTab: TabItem = .display
  #endif

  @Binding var settings: Settings
  @Binding var currentUser: Sweet.UserModel?
  @Binding var loginUsers: [Sweet.UserModel]

  public init(
    settings: Binding<Settings>,
    currentUser: Binding<Sweet.UserModel?>,
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

  @ViewBuilder
  func tabContent(tab: TabItem) -> some View {
    switch tab {
    #if !os(macOS)
      case .appIcon: IconSettingsView()
    #endif
    case .customClient: CustomClientSettingsView(currentUser: $currentUser, loginUsers: $loginUsers)
    case .display: DisplaySettingsView(settings: $settings)
    case .license: LicenseView()
    case .tab: TabSettingsView(settings: $settings)
    }
  }

  @ViewBuilder
  var accountSection: some View {
    Section("Account") {
      ForEach(loginUsers) { user in
        NavigationLink {
          AccountDetailView(userID: currentUser!.id, user: user)
        } label: {
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

  }

  #if os(macOS)
    public var body: some View {
      NavigationSplitView {
        List(selection: $selectedTab) {
          accountSection

          ForEach(SectionType.allCases) { type in
            Section(type.rawValue.uppercased()) {
              ForEach(TabItem.allCases.filter { $0.item.sectionType == type }) { tabItem in
                Label(tabItem.item.title, systemImage: tabItem.item.icon)
                  .tag(tabItem)
              }
            }
          }
        }
      } detail: {
        NavigationStack {
          tabContent(tab: selectedTab)
            .navigationTitle(selectedTab.item.title)
        }
      }
      .frame(minWidth: 500, minHeight: 500)
    }
  #else
    public var body: some View {
      NavigationStack {
        List {
          accountSection

          ForEach(SectionType.allCases) { type in
            Section(type.rawValue.uppercased()) {
              ForEach(TabItem.allCases.filter { $0.item.sectionType == type }) { tabItem in
                NavigationLink {
                  tabContent(tab: tabItem)
                    .navigationTitle(tabItem.item.title)
                } label: {
                  Label(tabItem.item.title, systemImage: tabItem.item.icon)
                }
              }
            }
          }
        }
        .onChange(of: settings) { newValue in
          Secure.settings = newValue
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayModeIfAvailable(.large)
      }
    }
  #endif
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

extension SettingsView {
  enum SectionType: String, CaseIterable, Identifiable {
    case general
    case about

    var id: String { rawValue }
  }

  enum TabItem: String, Identifiable, CaseIterable {
    case display
    case tab
    #if !os(macOS)
      case appIcon
    #endif

    case license
    case customClient

    var id: String { rawValue }

    struct Item {
      let title: String
      let icon: String
      let sectionType: SectionType
    }

    var item: Item {
      switch self {
      #if !os(macOS)
        case .appIcon:
          return Item(title: "App Icon", icon: "rectangle.grid.2x2", sectionType: .general)
      #endif
      case .display: return Item(title: "Display", icon: "iphone", sectionType: .general)
      case .tab: return Item(title: "Tab", icon: "dock.rectangle", sectionType: .general)
      case .license: return Item(title: "License", icon: "lock.shield", sectionType: .about)
      case .customClient:
        return Item(title: "Custom Client", icon: "key.horizontal", sectionType: .about)
      }
    }
  }
}
