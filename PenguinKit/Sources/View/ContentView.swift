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
    loginUsers: Binding<[Sweet.UserModel]>,
    subscriptionExpireDate: Binding<Date?>
  ) {
    self._settings = settings
    self._currentUser = currentUser
    self._loginUsers = loginUsers
    self._subscriptionExpireDate = subscriptionExpireDate
  }

  @SceneStorage("ContentView.selectedTab") var selectedTab: TabItem = .timeline

  @Binding var currentUser: Sweet.UserModel?
  @Binding var loginUsers: [Sweet.UserModel]
  @Binding var settings: Settings
  @Binding var subscriptionExpireDate: Date?
  
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
        subscriptionExpireDate: $subscriptionExpireDate,
        userID: currentUser.id
      )
    case .list:
      ListsView(
        viewModel: ListsViewModel(userID: currentUser.id),
        loginUsers: $loginUsers,
        currentUser: $currentUser,
        settings: $settings,
        subscriptionExpireDate: $subscriptionExpireDate
      )
    case .search:
      SearchView(
        viewModel: .init(userID: currentUser.id, searchSettings: .init(excludeRetweet: true)),
        loginUsers: $loginUsers,
        currentUser: $currentUser,
        settings: $settings,
        subscriptionExpireDate: $subscriptionExpireDate
      )
    case .space:
      SearchSpacesView(
        viewModel: SearchSpacesViewModel(userID: currentUser.id),
        loginUsers: $loginUsers,
        currentUser: $currentUser,
        settings: $settings,
        subscriptionExpireDate: $subscriptionExpireDate
      )
    case .bookmark:
      BookmarksNavigationView(
        loginUsers: $loginUsers,
        currentUser: $currentUser,
        settings: $settings,
        subscriptionExpireDate: $subscriptionExpireDate,
        userID: currentUser.id
      )
    case .like:
      LikeNavigationView(
        loginUsers: $loginUsers,
        currentUser: $currentUser,
        settings: $settings,
        subscriptionExpireDate: $subscriptionExpireDate,
        userID: currentUser.id
      )
    case .mention:
      MentionNavigationView(
        userID: currentUser.id,
        loginUsers: $loginUsers,
        currentUser: $currentUser,
        settings: $settings,
        subscriptionExpireDate: $subscriptionExpireDate
      )
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
      if subscriptionExpireDate == nil || subscriptionExpireDate! < Date.now {
        SubscriptionView(expireDate: $subscriptionExpireDate)
      }
      else if let currentUser {
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
#if os(macOS)
  let iconName = NSApplication.shared.iconName
#else
  let iconName = UIApplication.shared.iconName
#endif
        let icon = Icon.icons.first { $0.iconName == iconName }!
        
        VStack {
          Image(iconName, bundle: .module)
            .resizable()
            .scaledToFit()
            .cornerRadius(15)
            .padding(40)

          Text("Thanks for using Penguin!")
            .font(.title)
            .bold()

          LoginView(currentUser: $currentUser, loginUsers: $loginUsers) {
            Text("\(Image(systemName: "lock.circle")) Login with Twitter")
              .padding(8)
              .bold()
          }
          .buttonStyle(.borderedProminent)
          .buttonBorderShape(.roundedRectangle)
          .padding()
          
          Button {
            isPresentedSettingsView.toggle()
          } label: {
            Label("Settings", systemImage: "gear")
              .padding(8)
              .bold()
          }
          .buttonStyle(.borderedProminent)
          .buttonBorderShape(.roundedRectangle)
          .sheet(isPresented: $isPresentedSettingsView) {
            SettingsView(
              settings: $settings,
              currentUser: $currentUser,
              loginUsers: $loginUsers,
              subscriptionExpireDate: $subscriptionExpireDate
            )
          }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(icon.color.opacity(0.4))
        .tabItem {
          Label("Login", systemImage: "person")
        }
      }
    }
    .task {
      let result = await SubscribeManager.purchasedProducts()
      // TODO エラーハンドルするべきかも
      subscriptionExpireDate = try? result?.payloadValue.expirationDate
      Secure.subscriptionExpireDate = subscriptionExpireDate
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
      settings: .constant(Settings()),
      currentUser: .constant(nil),
      loginUsers: .constant([]),
      subscriptionExpireDate: .constant(.now)
    )
  }
}
