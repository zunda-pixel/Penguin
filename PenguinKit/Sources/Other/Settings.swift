//
// Settings.swift
//

import SwiftUI

public struct Settings: Codable, Equatable {
  var colorType: ColorType

  var userNameDisplayMode: DisplayUserNameMode
  var dateFormat: DateFormatMode
  var tabs: [TabItem]
  var tabStyle: TabStyle

  private enum CodingKeys: CodingKey {
    case colorType
    case userNameDisplayMode
    case dateFormat
    case tabs
    case tabStyle
  }

  public init() {
    colorType = .cyan
    userNameDisplayMode = .all
    dateFormat = .relative
    tabs = [.timeline, .mention, .list, .search, .like]

    #if os(macOS)
    tabStyle = .split
    #else
    tabStyle = UIDevice.current.userInterfaceIdiom == .phone ? .tab : .split
    #endif
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    let colorType = try container.decode(String.self, forKey: .colorType)
    self.colorType = ColorType(rawValue: colorType)!

    let userNameDisplayMode = try container.decode(String.self, forKey: .userNameDisplayMode)
    self.userNameDisplayMode = .init(rawValue: userNameDisplayMode)!

    let dateFormat = try container.decode(String.self, forKey: .dateFormat)
    self.dateFormat = .init(rawValue: dateFormat)!

    let tabs = try container.decode([String].self, forKey: .tabs)
    self.tabs = tabs.map { TabItem(rawValue: $0)! }

    let tabStyle = try container.decode(String.self, forKey: .tabStyle)
    self.tabStyle = TabStyle(rawValue: tabStyle)!
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(colorType.rawValue, forKey: .colorType)
    try container.encode(userNameDisplayMode.rawValue, forKey: .userNameDisplayMode)
    try container.encode(dateFormat.rawValue, forKey: .dateFormat)
    try container.encode(tabs.map(\.rawValue), forKey: .tabs)
    try container.encode(tabStyle.rawValue, forKey: .tabStyle)
  }
}

enum DisplayUserNameMode: String, CaseIterable, Identifiable {
  case all = "All"
  case onlyDisplayName = "Only DisplayName"
  case onlyUserName = "Only UserName"

  var id: String { rawValue }
}

enum DateFormatMode: String, CaseIterable, Identifiable {
  case absolute = "Absolute"
  case relative = "Relative"

  var id: String { rawValue }
}
