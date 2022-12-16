//
//  ColorSet.swift
//

import SwiftUI

enum ColorType: String, CaseIterable, Identifiable {
  case cyan = "Cyan"
  case blue = "Blue"
  case indigo = "Indigo"
  case green = "Green"
  case red = "Red"
  case orange = "Orange"
  case pink = "Pink"
  case yellow = "Yellow"
  case purple = "Purple"
  
  var id: String { rawValue }
  
  var colorSet : ColorSet {
    switch self {
    case .blue: return .blue
    case .cyan: return .cyan
    case .orange: return .orange
    case .pink: return .pink
    case .green: return .green
    case .yellow: return .yellow
    case .purple: return .purple
    case .indigo: return .indigo
    case .red: return .red
    }
  }
}

struct ColorSet: Codable, Equatable {
  let tintColor: Color
  let darkPrimaryColor: Color
  let darkSecondaryColor: Color
  let lightPrimaryColor: Color
  let lightSecondaryColor: Color
}

extension ColorSet {
  static let red = ColorSet(
    tintColor: .red,
    darkPrimaryColor: Color(.systemGray6),
    darkSecondaryColor: Color(.systemGroupedBackground),
    lightPrimaryColor: .white,
    lightSecondaryColor: Color(.systemGroupedBackground)
  )
  
  static let blue = ColorSet(
    tintColor: .accentColor,
    darkPrimaryColor: Color(.systemGray6),
    darkSecondaryColor: Color(.systemGroupedBackground),
    lightPrimaryColor: .white,
    lightSecondaryColor: Color(.systemGroupedBackground)
  )
  
  static let cyan = ColorSet(
    tintColor: .cyan,
    darkPrimaryColor: Color(.systemGray6),
    darkSecondaryColor: Color(.systemGroupedBackground),
    lightPrimaryColor: .white,
    lightSecondaryColor: Color(.systemGroupedBackground)
  )
  
  static let orange = ColorSet(
    tintColor: .orange,
    darkPrimaryColor: Color(.systemGray6),
    darkSecondaryColor: Color(.systemGroupedBackground),
    lightPrimaryColor: .white,
    lightSecondaryColor: Color(.systemGroupedBackground)
  )
  
  static let pink   = ColorSet(
    tintColor: .pink,
    darkPrimaryColor: Color(.systemGray6),
    darkSecondaryColor: Color(.systemGroupedBackground),
    lightPrimaryColor: .white,
    lightSecondaryColor: Color(.systemGroupedBackground)
  )
  
  static let green  = ColorSet(
    tintColor: .green,
    darkPrimaryColor: Color(.systemGray6),
    darkSecondaryColor: Color(.systemGroupedBackground),
    lightPrimaryColor: .white,
    lightSecondaryColor: Color(.systemGroupedBackground)
  )
  
  static let yellow = ColorSet(
    tintColor: .yellow,
    darkPrimaryColor: Color(.systemGray6),
    darkSecondaryColor: Color(.systemGroupedBackground),
    lightPrimaryColor: .white,
    lightSecondaryColor: Color(.systemGroupedBackground)
  )
  
  static let purple = ColorSet(
    tintColor: .purple,
    darkPrimaryColor: Color(.systemGray6),
    darkSecondaryColor: Color(.systemGroupedBackground),
    lightPrimaryColor: .white,
    lightSecondaryColor: Color(.systemGroupedBackground)
  )
  
  static let indigo = ColorSet(
    tintColor: .indigo,
    darkPrimaryColor: Color(.systemGray6),
    darkSecondaryColor: Color(.systemGroupedBackground),
    lightPrimaryColor: .white,
    lightSecondaryColor: Color(.systemGroupedBackground)
  )
}
