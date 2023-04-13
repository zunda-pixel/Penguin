//
//  NSApplication+Extension.swift
//

#if os(macOS)
  import AppKit

  extension NSApplication {
    var iconName: String { "AppIcon" }
  }
#endif
