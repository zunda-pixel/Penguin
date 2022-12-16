//
//  CGSize+Extension.swift
//

import CoreGraphics

extension CGSize {
  var center: CGPoint {
    return .init(x: self.width / 2, y: self.height / 2)
  }
}
