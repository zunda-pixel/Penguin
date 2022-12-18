//
//  ContentView.swift
//

import SwiftUI
import Sweet
import WidgetKit
import os

struct ContentView: View {
  @SceneStorage("ContentView.selectedTab") var selectedTab: TabItem = .timeline
  
  @State var currentUser: Sweet.UserModel? = Secure.currentUser
  @State var loginUsers: [Sweet.UserModel] = Secure.loginUsers
  @State var settings = Secure.settings
  
  @MainActor
  @ViewBuilder
  func tabView(currentUser: Sweet.UserModel, tabItem: TabItem) -> some View {
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
        userID: currentUser.id,
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
    WidgetCenter.shared.reloadAllTimelines()
    
    do {
      guard let activity = try await WidgetsManager.fetchLatestTweet(userID: userID) else {
        return
      }
      print(activity)
      // await activity.update(using: .init()) stateのアップデート。今回は意味ない
      // await activity.end() activityの削除
      
    } catch {
      Logger.main.error("\(error.localizedDescription)")
    }
  }
  
  @Environment(\.colorScheme) var colorScheme
  @State var schemeItem: SchemeItem?
  
  var body: some View {
    VStack {
      if let currentUser {
        TabView(selection: $selectedTab) {
          ForEach(settings.tabs) { tab in
            tabView(currentUser: currentUser, tabItem: tab)
              .tabItem {
                Label(tab.title, systemImage: tab.systemImage)
              }
              .tag(tab)
              .toolbarBackground(colorScheme == .dark ? settings.colorType.colorSet.darkPrimaryColor : settings.colorType.colorSet.lightPrimaryColor, for: .tabBar)
              .toolbarBackground(.visible, for: .tabBar)
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
          Image(systemName: "bird")
            .resizable()
            .scaledToFit()
            .padding(40)
            .foregroundColor(settings.colorType.colorSet.tintColor.opacity(0.5))
          
          Text("Thanks for using Penguin!")
            .font(.title)
            .bold()
          LoginView(currentUser: $currentUser, loginUsers: $loginUsers) {
            Text("\(Image(systemName: "lock.circle")) Login with Twitter")
              .bold()
              .padding()
              .background(RoundedRectangle(cornerRadius: 15).foregroundColor(settings.colorType.colorSet.tintColor.opacity(0.5)))
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
