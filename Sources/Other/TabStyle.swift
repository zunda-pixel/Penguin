//
//  TabStyle.swift
//

import Foundation

enum TabStyle: String, Identifiable, CaseIterable {
  var id: String { rawValue }
  
  case tab
  case split
}
