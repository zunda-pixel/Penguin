//
//  UIApplication+Extension.swift
//

#if canImport(UIKit)
  import UIKit

  extension UIApplication {
    static let primaryIconName = "AppIcon"
    var iconName: String { alternateIconName ?? UIApplication.primaryIconName }
  }
#endif
