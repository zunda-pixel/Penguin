//
//  UIApplication+Extension.swift
//

import UIKit

extension UIApplication {
  static let primaryIconName = "AppIcon"
  var iconName: String { alternateIconName ?? UIApplication.primaryIconName }
}
