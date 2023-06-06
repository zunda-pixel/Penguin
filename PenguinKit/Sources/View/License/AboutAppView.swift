//
//  LicenseView.swift
//

import SwiftUI

struct AboutAppView: View {
  var body: some View {
    List {
      Section("Penguin") {
        Link(destination: URL(string: "https://zunda-pixel.github.io/App/Penguin/PrivacyPolicy.md")!) {
          Label("Privacy Policy", systemImage: "hand.raised.square")
        }
        Link(destination: URL(string: "https://zunda-pixel.github.io/App/Penguin/Terms.md")!) {
          Label("Terms", systemImage: "lock.shield")
        }
      }
      
      Section("License") {
        ForEach(LicenseProvider.packages) { package in
          NavigationLink(package.name) {
            LicenseCell(package: package)
              .navigationTitle(package.name)
          }
        }
      }
    }
  }
}

struct AboutAppView_Previews: PreviewProvider {
  static var previews: some View {
    NavigationStack {
      AboutAppView()
    }
  }
}
