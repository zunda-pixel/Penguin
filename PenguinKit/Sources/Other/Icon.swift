//
//  Icon.swift
//

import SwiftUI

struct Icon: Identifiable, Hashable {
  let id = UUID()
  let name: String
  let iconName: String
  let color: Color

  static let icons: [Icon] = [
    .init(name: "Primary", iconName: "AppIcon", color: .indigo),
    .init(name: "Secondary", iconName: "AppIcon1", color: .purple),
  ]
}
