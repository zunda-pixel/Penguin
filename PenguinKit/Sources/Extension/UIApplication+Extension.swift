//
//  UIApplication+Extension.swift
//

#if canImport(UIKit)
  import UIKit

  extension UIApplication {
    var iconName: String { alternateIconName ?? Self.primaryIconName }
    static let primaryIconName: String = "AppIcon"
  }
#endif
