//
//  Configuration.swift
//

import Foundation

struct Configuration {
  let bundle: Bundle

  #if os(macOS)
    var primaryIconName: String {
      return bundle.infoDictionary!["CFBundleIconName"] as! String
    }
  #else
    var primaryIconName: String {
      let icons = bundle.infoDictionary!["CFBundleIcons"] as! [String: Any]
      let primaryIcon = icons["CFBundlePrimaryIcon"] as! [String: Any]
      let iconName = primaryIcon["CFBundleIconName"] as! String
      return iconName
    }
  #endif
}
