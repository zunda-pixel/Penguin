//
//  ContentView.swift
//

import Sweet
import SwiftUI
import WidgetKit

public struct ContentView: View {
  public init(
    settings: Binding<Settings>,
    currentUser: Binding<Sweet.UserModel?>,
    loginUsers: Binding<[Sweet.UserModel]>
  ) {
    self._settings = settings
    self._currentUser = currentUser
    self._loginUsers = loginUsers
  }

  @SceneStorage("ContentView.selectedTab") var selectedTab: TabItem = .timeline

  @Binding var currentUser: Sweet.UserModel?
  @Binding var loginUsers: [Sweet.UserModel]
  @Binding var settings: Settings

  @State var isPresentedSettingsView = false

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
      .id(currentUser.id)
    case .search:
      SearchView(
        viewModel: .init(userID: currentUser.id, searchSettings: .init(excludeRetweet: true)),
        loginUsers: $loginUsers,
        currentUser: $currentUser,
        settings: $settings
      )
      .id(currentUser.id)
    case .space:
      SearchSpacesView(
        viewModel: SearchSpacesViewModel(userID: currentUser.id),
        loginUsers: $loginUsers,
        currentUser: $currentUser,
        settings: $settings
      )
      .id(currentUser.id)
    case .bookmark:
      BookmarksNavigationView(
        viewModel: BookmarksViewModel(userID: currentUser.id),
        loginUsers: $loginUsers,
        currentUser: $currentUser,
        settings: $settings,
        userID: currentUser.id
      )
      .id(currentUser.id)
    case .like:
      LikeNavigationView(
        viewModel: LikesViewModel(userID: currentUser.id, ownerID: currentUser.id),
        loginUsers: $loginUsers,
        currentUser: $currentUser,
        settings: $settings
      )
      .id(currentUser.id)
    case .mention:
      MentionNavigationView(
        viewModel: UserMentionsViewModel(userID: currentUser.id, ownerID: currentUser.id),
        loginUsers: $loginUsers,
        currentUser: $currentUser,
        settings: $settings
      )
      .id(currentUser.id)
    }
  }

  func fetchLatestTweet(userID: String) async {
    WidgetCenter.shared.reloadAllTimelines()

    #if canImport(ActivityKit)
      do {
        guard let activity = try await WidgetsManager.fetchLatestTweet(userID: userID) else {
          return
        }
        print(activity)
        // await activity.update(using: .init()) stateのアップデート。今回は意味ない
        // await activity.end() activityの削除

      } catch {
        let errorHandle = ErrorHandle(error: error)
        errorHandle.log()
      }
    #endif
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
        #if !os(macOS)
          .toolbarBackground(
            colorScheme == .dark
              ? settings.colorType.colorSet.darkPrimaryColor
              : settings.colorType.colorSet.lightPrimaryColor, for: .tabBar
          )
          .toolbarBackground(.visible, for: .tabBar)
        #endif
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
      #if !os(macOS)
        .toolbarBackground(
          colorScheme == .dark
            ? settings.colorType.colorSet.darkPrimaryColor
            : settings.colorType.colorSet.lightPrimaryColor, for: .tabBar
        )
        .toolbarBackground(.visible, for: .tabBar)
      #endif
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
          #if os(macOS)
            let icon = Icon.icons.first { $0.iconName == NSApplication.shared.iconName }
          #else
            let icon = Icon.icons.first { $0.iconName == UIApplication.shared.iconName }
          #endif

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

          Button {
            isPresentedSettingsView.toggle()
          } label: {
            Label("Settings", systemImage: "gear")
          }
          .bold()
          .padding()
          .background(
            RoundedRectangle(cornerRadius: 15).foregroundColor(
              settings.colorType.colorSet.tintColor.opacity(0.5))
          )
          .sheet(isPresented: $isPresentedSettingsView) {
            SettingsView(settings: $settings, currentUser: $currentUser, loginUsers: $loginUsers)
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
    .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
    .tint(settings.colorType.colorSet.tintColor)
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView(
      settings: .constant(Settings()), currentUser: .constant(nil), loginUsers: .constant([]))
  }
}
