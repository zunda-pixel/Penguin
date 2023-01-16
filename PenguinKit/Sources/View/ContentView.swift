//
//  ContentView.swift
//

import Sweet
import SwiftUI
import WidgetKit

public struct ContentView: View {
  public init() {}

  @SceneStorage("ContentView.selectedTab") var selectedTab: TabItem = .timeline

  @State var currentUser: Sweet.UserModel? = Secure.currentUser
  @State var loginUsers: [Sweet.UserModel] = Secure.loginUsers
  @State var settings = Secure.settings

  @MainActor
  @ViewBuilder
  func tabViewContent(currentUser: Sweet.UserModel, tabItem: TabItem) -> some View {
    switch tabItem {
    case .timeline:
      ReverseChronologicalNavigationView(
        loginUsers: $loginUsers,
        currentUser: $currentUser,
        settings: $settings,
        userID: currentUser.id
      )
    case .list:
      ListsView(
        viewModel: ListsViewModel(userID: currentUser.id),
        loginUsers: $loginUsers,
        currentUser: $currentUser,
        settings: $settings
      )
    case .search:
      SearchView(
        viewModel: .init(userID: currentUser.id, searchSettings: .init(excludeRetweet: true)),
        loginUsers: $loginUsers,
        currentUser: $currentUser,
        settings: $settings
      )
    case .space:
      SearchSpacesView(
        viewModel: SearchSpacesViewModel(userID: currentUser.id),
        loginUsers: $loginUsers,
        currentUser: $currentUser,
        settings: $settings
      )
    case .bookmark:
      BookmarksNavigationView(
        loginUsers: $loginUsers,
        currentUser: $currentUser,
        settings: $settings,
        userID: currentUser.id
      )
    case .like:
      LikeNavigationView(
        loginUsers: $loginUsers,
        currentUser: $currentUser,
        settings: $settings,
        userID: currentUser.id
      )
    case .mention:
      MentionNavigationView(
        userID: currentUser.id,
        loginUsers: $loginUsers,
        currentUser: $currentUser,
        settings: $settings
      )
    }
  }

  func fetchLatestTweet(userID: String) async {
    //    WidgetCenter.shared.reloadAllTimelines()
    //
    //    do {
    //      guard let activity = try await WidgetsManager.fetchLatestTweet(userID: userID) else {
    //        return
    //      }
    //      print(activity)
    //      // await activity.update(using: .init()) stateのアップデート。今回は意味ない
    //      // await activity.end() activityの削除
    //
    //    } catch {
    //      let errorHandle = ErrorHandle(error: error)
    //      errorHandle.log()
    //    }
  }

  @Environment(\.colorScheme) var colorScheme
  @State var schemeItem: SchemeItem?

  @ViewBuilder
  @MainActor
  func tabView(currentUser: Sweet.UserModel) -> some View {
    TabView(selection: $selectedTab) {
      ForEach(settings.tabs) { tab in
        tabViewContent(currentUser: currentUser, tabItem: tab)
          .tabItem {
            Label(tab.title, systemImage: tab.systemImage)
          }
          .tag(tab)
          .toolbarBackground(
            colorScheme == .dark
              ? settings.colorType.colorSet.darkPrimaryColor
              : settings.colorType.colorSet.lightPrimaryColor, for: .tabBar
          )
          .toolbarBackground(.visible, for: .tabBar)
      }
    }
  }

  @ViewBuilder
  @MainActor
  func splitView(currentUser: Sweet.UserModel) -> some View {
    NavigationSplitView {
      let binding: Binding<TabItem?> = .init {
        selectedTab
      } set: { newTab in
        if let newTab {
          selectedTab = newTab
        }
      }

      List(selection: binding) {
        ForEach(settings.tabs) { tab in
          Label(tab.title, systemImage: tab.systemImage)
            .tag(tab)
        }
      }
    } detail: {
      tabViewContent(currentUser: currentUser, tabItem: selectedTab)
        .toolbarBackground(
          colorScheme == .dark
            ? settings.colorType.colorSet.darkPrimaryColor
            : settings.colorType.colorSet.lightPrimaryColor, for: .tabBar
        )
        .toolbarBackground(.visible, for: .tabBar)
    }
    .navigationSplitViewStyle(.balanced)
  }

  public var body: some View {
    VStack {
      if let currentUser {
        Group {
          switch settings.tabStyle {
          case .tab: tabView(currentUser: currentUser)
          case .split: splitView(currentUser: currentUser)
          }
        }
        .task {
          await fetchLatestTweet(userID: currentUser.id)
        }
        .onOpenURL { url in
          self.schemeItem = .from(url: url)
        }
        .sheet(item: $schemeItem) { schemeItem in
          OnlineNavigationView(userID: currentUser.id, schemeItem: schemeItem)
        }
      } else {
        VStack {
          let icon = Icon.icons.first { $0.iconName == UIApplication.shared.iconName }

          Image(icon!.iconName, bundle: .module)
            .resizable()
            .scaledToFit()
            .cornerRadius(15)
            .padding(40)

          Text("Thanks for using Penguin!")
            .font(.title)
            .bold()

          LoginView(currentUser: $currentUser, loginUsers: $loginUsers) {
            Text("\(Image(systemName: "lock.circle")) Login with Twitter")
              .bold()
              .padding()
              .background(
                RoundedRectangle(cornerRadius: 15).foregroundColor(
                  settings.colorType.colorSet.tintColor.opacity(0.5)))
          }
        }
        .tabItem {
          Label("Login", systemImage: "person")
        }
      }
    }
    .fontDesign(.rounded)
    .environment(\.settings, settings)
    .environment(\.loginUsers, loginUsers)
    .tint(settings.colorType.colorSet.tintColor)
  }
}
