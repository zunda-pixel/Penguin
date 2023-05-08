//
//  LicenseView.swift
//

import SwiftUI
import AttributedText
import Algorithms

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
  
  func string(data: [UInt8]) -> String {
    let chunkCipher = data.chunks(ofCount: 8)
    
    let lines = chunkCipher.map { chunk in
      let values = chunk.map { String(format: "0x%x", $0) }
      return values.joined(separator: ", ")
    }
    
    return lines.joined(separator: ",\n")
  }
    
  var body: some View {
    List {
      Text(string(data: Env.cipher))
        .textSelection(.enabled)
      
      Text(string(data: Env._clientKey))
        .textSelection(.enabled)
      
      Text(string(data: Env._clientSecretKey))
        .textSelection(.enabled)
      
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
