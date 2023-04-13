//
//  NSApplication+Extension.swift
//

#if os(macOS)
  import AppKit

  extension NSApplication {
    var iconName: String { "AppIcon" }

    func showSettingsWindows() {
      // https://stackoverflow.com/a/75712446/15098239
      self.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
    }
  }
#endif
