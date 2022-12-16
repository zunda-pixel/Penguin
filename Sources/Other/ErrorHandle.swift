//
//  ErrorHandle.swift
//

import Foundation
import Sweet

struct ErrorHandle {
  var error: any Error
  
  var title: String {
    switch error {
    case let twitterError as Sweet.TwitterError:
      return twitterError.errorDescription!
    default:
      return error.localizedDescription
    }
  }
  
  var message: String {
    switch error {
    case let twitterError as Sweet.TwitterError:
      return twitterError.recoverySuggestion!
    default:
      return error.localizedDescription
    }
  }
}
