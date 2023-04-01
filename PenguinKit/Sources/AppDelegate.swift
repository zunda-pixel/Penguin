//
//  AppDelegate.swift
//

import Firebase
import Foundation
import SwiftUI

#if os(macOS)
  public final class AppDelegate: NSResponder, NSApplicationDelegate {
    public func applicationDidFinishLaunching(_ notification: Notification) {
      FirebaseApp.configure()
    }
  }
#else
  public final class AppDelegate: UIResponder, UIApplicationDelegate {
    public func application(
      _ application: UIApplication,
      didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
      FirebaseApp.configure()
      return true
    }
  }
#endif
