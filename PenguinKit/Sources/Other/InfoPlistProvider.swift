//
//  InfoPlistProvider.swift
//

import Foundation

struct InfoPlistProvider {
  static var bundleIdentifier: String {
    Bundle.main.object(forInfoDictionaryKey: "CFBundleIdentifier") as! String
  }
}
