//
//  ErrorHandle.swift
//

import Foundation
import Sweet
import os

public struct ErrorHandle {
  let error: any Error
  
  public init(error: any Error) {
    self.error = error
  }
  
  var title: String {
    switch error {
    case let twitterError as Sweet.TwitterError:
      return twitterError.errorDescription!
    case let twitterError as Sweet.TwitterError:
      return twitterError.errorDescription!
    case let requestError as Sweet.RequestError:
      return requestError.errorDescription!
    case let unknownError as Sweet.UnknownError:
      return unknownError.errorDescription!
    default:
      return error.localizedDescription
    }
  }
  
  var message: String {
    switch error {
    case let twitterError as Sweet.TwitterError:
      return twitterError.recoverySuggestion!
    case let requestError as Sweet.RequestError:
      return requestError.recoverySuggestion!
    case let unknownError as Sweet.UnknownError:
      return unknownError.recoverySuggestion!
    default:
      return error.localizedDescription
    }
  }
  
  var logMessage: String {
    switch error {
    case let twitterError as Sweet.TwitterError:
      return twitterError.errorDescription!
    case let requestError as Sweet.RequestError:
      return requestError.logMessage
    case let unknownError as Sweet.UnknownError:
      return unknownError.logMessage
    default:
      return error.localizedDescription
    }
  }
  
  public func log() {
    Logger.main.error("""
Title: \(title)
Message: \(message)
Log: \(logMessage)
"""
    )
  }
}
