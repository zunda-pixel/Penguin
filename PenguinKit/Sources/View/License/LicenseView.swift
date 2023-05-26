//
//  LicenseView.swift
//

import SwiftUI

struct LicenseView: View {
  var body: some View {
    List {
      ForEach(LicenseProvider.packages) { package in
        NavigationLink(package.name) {
          LicenseCell(package: package)
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
