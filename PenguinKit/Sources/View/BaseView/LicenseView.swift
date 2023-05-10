//
//  LicenseView.swift
//

import AttributedText
import SwiftUI

struct LicenseView: View {
  @Environment(\.openURL) var openURL

  func cell(package: Package) -> some View {
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

  var body: some View {
    List {
      ForEach(LicenseList.packages) { package in
        NavigationLink(package.name) {
          cell(package: package)
            .navigationTitle(package.name)
        }
      }
    }
  }
}

struct LicenseView_Previews: PreviewProvider {
  static var previews: some View {
    NavigationStack {
      LicenseView()
    }
  }
}

extension AttributedText {
  init(text: String) {
    self.init(text: text, prefixes: [], urlContainer: .init()) { _, _ in }
  }
}
