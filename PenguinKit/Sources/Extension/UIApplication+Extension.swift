//
//  UIApplication+Extension.swift
//

#if canImport(UIKit)
  import UIKit

  extension UIApplication {
    var iconName: String { alternateIconName ?? Configuration(bundle: .main).primaryIconName }
  }
#endif
