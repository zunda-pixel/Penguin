//
//  AppDelegate.swift
//

import Foundation
import SwiftUI
import Firebase

#if os(macOS)
public class AppDelegate: NSResponder, NSApplicationDelegate {
  public func applicationDidFinishLaunching(_ notification: Notification) {
    FirebaseApp.configure()
  }
}
#else
public class AppDelegate: UIResponder, UIApplicationDelegate {
  public func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
  ) -> Bool {
    FirebaseApp.configure()
    return true
  }
}
#endif
