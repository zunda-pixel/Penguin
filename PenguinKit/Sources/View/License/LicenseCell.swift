//
//  LicenseCell.swift
//

import SwiftUI
import AttributedText

struct LicenseCell: View {
  @Environment(\.openURL) var openURL
  let package: Package
  
  var body: some View {
    ScrollView {
      AttributedText(text: package.license)
        .font(.caption)
        .frame(maxWidth: .infinity)
    }
    .toolbar {
      ToolbarItem {
        Button {
          openURL(package.location)
        } label: {
          Image(systemName: "safari")
        }
      }
    }
  }
}

struct LicenseCell_Previews: PreviewProvider {
  static var previews: some View {
    LicenseCell(package: .init(name: "Package Name", location: .init(string: "https://google.com")!, license: "License Content"))
  }
}

private extension AttributedText {
  init(text: String) {
    self.init(text: text, prefixes: [], urlContainer: .init()) { _, _ in }
  }
}
