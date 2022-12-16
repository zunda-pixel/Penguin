//
//  OGPCardViewModel.swift
//

import Foundation
import OpenGraph

@MainActor class OGPCardViewModel: ObservableObject {
  let url: URL

  init(url: URL) {
    self.url = url
  }

  @Published var ogp: OGPValue?

  @Published var errorHandle: ErrorHandle?

  func fetchOGP() async {
    do {
      self.ogp = try await OGPManager.fetchOGPData(url: url)
    } catch OpenGraphResponseError.unexpectedStatusCode(let statusCode) {
      print("OpenGraphResponseError.unexpectedStatusCode(statusCode: \(statusCode)")
    }
    catch {
      errorHandle = ErrorHandle(error: error)
    }
  }
}
