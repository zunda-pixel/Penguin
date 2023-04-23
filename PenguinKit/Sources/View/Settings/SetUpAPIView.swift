//
//  APIDescriptionView.swift
//

import SwiftUI

struct SetUpAPIView: View {
  var body: some View {
    List {
      Text("Set up User authentication settings as follows.")

      Link(destination: URL(string: "https://developer.twitter.com/en/portal/projects/")!) {
        Text("Twitter Developer Portal")
      }

      Picker("App Permission", selection: .constant(AppPermissions.readAndWriteAndDirectMessage)) {
        ForEach(AppPermissions.allCases) { permission in
          Text(permission.rawValue)
            .tag(permission)
        }
      }
      .pickerStyle(.inline)

      Picker("App Type", selection: .constant(AppType.nativeApp)) {
        ForEach(AppType.allCases) { type in
          Text(type.rawValue)
            .tag(type)
        }
      }
      .pickerStyle(.inline)

      Section("App info") {
        LabeledContent("Callback URL", value: "penguin://")
        LabeledContent("Website URL", value: "https://example.com")
      }
    }
  }
}

extension SetUpAPIView {
  enum AppPermissions: String, CaseIterable, Identifiable {
    case read = "Read"
    case readAndWrite = "Read and write"
    case readAndWriteAndDirectMessage = "Read and write and Direct message"

    var id: String { rawValue }
  }

  enum AppType: String, CaseIterable, Identifiable {
    case nativeApp = "NativeApp"
    case webApp = "Web App, Automated App or Bot"

    var id: String { rawValue }
  }
}

struct APIDescriptionView_Previews: PreviewProvider {
  static var previews: some View {
    SetUpAPIView()
  }
}
