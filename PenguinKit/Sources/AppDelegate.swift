//
//  AppDelegate.swift
//

import Foundation
import SwiftUI
import Firebase

public class AppDelegate: UIResponder, UIApplicationDelegate {
  public func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
  ) -> Bool {
    FirebaseApp.configure()
    return true
  }
}
