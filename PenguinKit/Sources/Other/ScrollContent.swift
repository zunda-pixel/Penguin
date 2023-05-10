//
//  ScrollContent.swift
//

import SwiftUI

struct ScrollContent<Content: Hashable>: Equatable {
  let id: UUID
  let contentID: Content
  let anchor: UnitPoint

  init(contentID: Content, anchor: UnitPoint) {
    self.id = UUID()
    self.contentID = contentID
    self.anchor = anchor
  }
}
