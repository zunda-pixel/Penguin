import SwiftUI
import PenguinKit
import Sweet

@main
struct PenguinApp: App {  
  @State var settings: PenguinKit.Settings = Secure.settings
  @State var currentUser: Sweet.UserModel? = Secure.currentUser
  @State var loginUsers: [Sweet.UserModel] = Secure.loginUsers
  
  var body: some Scene {
    WindowGroup {
      ContentView(settings: $settings, currentUser: $currentUser, loginUsers: $loginUsers)
        .handlesExternalEvents(preferring: ["penguin"], allowing: []) // prevent to generate new windows from url scheme
    }
#if os(macOS)
    SwiftUI.Settings {
      SettingsView(settings: $settings, currentUser: $currentUser, loginUsers: $loginUsers)
        .frame(minWidth: 500, minHeight: 500)
    }
#endif
  }
}
