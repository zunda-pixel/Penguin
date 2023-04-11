//
//  NSApplication+Extension.swift
//

#if os(macOS)
  import AppKit

  extension NSApplication {
    var iconName: String { Configuration(bundle: .main).primaryIconName }
  }
#endif
