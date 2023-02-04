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
    case let requestError as Sweet.RequestError:
      return requestError.errorDescription!
    case let authorizationError as Sweet.AuthorizationError:
      return authorizationError.errorDescription!
    case let unknownError as Sweet.UnknownError:
      return unknownError.errorDescription!
    case let localError as LocalAuthorizationError:
      return localError.errorDescription!
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
    case let authorizationError as Sweet.AuthorizationError:
      return authorizationError.recoverySuggestion!
    case let unknownError as Sweet.UnknownError:
      return unknownError.recoverySuggestion!
    case let localError as LocalAuthorizationError:
      return localError.recoverySuggestion!
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
    case let authorizationError as Sweet.AuthorizationError:
      return authorizationError.logMessage
    case let unknownError as Sweet.UnknownError:
      return unknownError.logMessage
    case let localError as LocalAuthorizationError:
      return localError.logMessage
    default:
      return error.localizedDescription
    }
  }

  public func log() {
    Logger.main.error(
      """
      Title: \(title)
      Message: \(message)
      Log: \(logMessage)
      """
    )
  }
}
