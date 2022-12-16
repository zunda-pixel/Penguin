//
// URL+Extension.swift
//

import Foundation

extension URL {
  var queryItems: [URLQueryItem] {
    let components = URLComponents(url: self, resolvingAgainstBaseURL: true)
    return components?.queryItems ?? []
  }
}
