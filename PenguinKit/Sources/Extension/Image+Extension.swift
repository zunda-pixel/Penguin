//
//  Image+Extension.swift
//

import SwiftUI

extension Image {
  @ViewBuilder
  static var verifiedMark: some View {
    Image(systemName: "checkmark.seal")
      .symbolVariant(.fill)
      .foregroundStyle(.cyan)
  }
}
