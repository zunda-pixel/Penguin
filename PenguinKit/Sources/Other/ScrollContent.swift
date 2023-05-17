//
//  ScrollContent.swift
//

import SwiftUI

struct ScrollContent<Content: Hashable>: Equatable {
  let id: UUID
  let contentID: Content
  let anchor: ScrollPoint

  init(
    contentID: Content,
    anchor: ScrollPoint
  ) {
    self.id = UUID()
    self.contentID = contentID
    self.anchor = anchor
  }
}

enum ScrollPoint {
  case top, bottom, center

  var unitPoint: UnitPoint {
    switch self {
    case .top: return .top
    case .center: return .center
    case .bottom: return .bottom
    }
  }
}
