//
//  TwitterError.swift
//

import Foundation
import Sweet

extension Sweet.TwitterError: LocalizedError {
  public var errorDescription: String? {
    switch self {
    case .followError: return "Follow Error"
    case .listMemberError: return "List Member Error"
    case .updateListError: return "Update List Error"
    case .deleteListError: return "Delete List Error"
    case .pinnedListError: return "Pin List Error"
    case .hideReplyError: return "Hide Replay Error"
    case .likeTweetError: return "Like Tweet Error"
    case .deleteTweetError: return "Delete Tweet Error"
    case .retweetError: return "Retweet Tweet Error"
    case .blockUserError: return "Block User Error"
    case .muteUserError: return "Mute User Error"
    case .bookmarkError: return "Bookmark Error"
    case .uploadCompliance: return "Upload Compliance Error"
    }
  }

  public var recoverySuggestion: String? {
    switch self {
    case .followError: return "Please Retry Follow"
    case .listMemberError: return "Please Retry Manage Member"
    case .updateListError: return "Please Retry Update List"
    case .deleteListError: return "Please Retry Delete List"
    case .pinnedListError: return "Please Retry Pin List"
    case .hideReplyError: return "Please Retry Hide Reply"
    case .likeTweetError: return "Please Retry Like Tweet"
    case .deleteTweetError: return "Please Retry Delete Tweet"
    case .retweetError: return "Please Retry Retweet"
    case .blockUserError: return "Please Retry Manage Block"
    case .muteUserError: return "Please Retry Manage Mute"
    case .bookmarkError: return "Please Retry Manage Bookmark"
    case .uploadCompliance: return "Please Contact with Developer"
    }
  }
}

extension Sweet.UnknownError: LocalizedError {
  public var errorDescription: String? {
    return "UnknownError"
  }

  public var recoverySuggestion: String? {
    return "Please Contact with Developer"
  }

  public var logMessage: String {
    return """
      UnknownError
      \(request)
      \(String(data: data, encoding: .utf8)!)
      \(response?.debugDescription ?? "") 
      """
  }
}

extension Sweet.RequestError: LocalizedError {
  public var errorDescription: String? {
    switch self {
    case .accountLocked: return "Developer Account Locked"
    case .forbidden(detail: _): return "Forbidden Request"
    case .tooManyAccess: return "Too Many Access"
    case .unAuthorized: return "UnAuthorized Request"
    case .unsupportedAuthentication(detail: _): return "Unsupported Authorization"
    case .invalidRequest(response: _): return "Invalid Request"
    }
  }

  public var recoverySuggestion: String? {
    return "Please Contact with Developer"
  }

  public var logMessage: String {
    switch self {
    case .accountLocked: return "Developer Account Locked"
    case .forbidden(detail: _): return "Forbidden Request"
    case .tooManyAccess: return "Too Many Access"
    case .unAuthorized: return "UnAuthorized Request"
    case .unsupportedAuthentication(let detail):
      return "Unsupported Authorization(detail: \(detail))"
    case .invalidRequest(response: let request):
      return """
        Invalid Request
        \(request.title)
        \(request.detail)
        \(request.type)
        \(request.errors)
        """
    }
  }
}

extension Sweet.AuthorizationError: LocalizedError {
  public var errorDescription: String? {
    switch self {
    case .invalidClient: return "Invalid Client"
    case .invalidRequest: return "Invalid Request"
    case .unknown: return "Unknown Authorization Error"
    }
  }

  public var recoverySuggestion: String? {
    return "Please Contact with Developer"
  }

  public var logMessage: String {
    switch self {
    case .invalidRequest: return "Invalid Request"
    case .invalidClient: return "Invalid Client"
    case .unknown(let response):
      return """
        \(response.error)
        \(response.errorDescription)
        """
    }
  }
}

extension LocalAuthorizationError: LocalizedError {
  public var errorDescription: String? {
    "Authorization Error"
  }

  public var recoverySuggestion: String? {
    return "Try Again"
  }

  public var logMessage: String {
    switch self {
    case .noRefreshToken: return "No RefreshToken"
    case .noBearerToken: return "No BearerToken"
    case .noExpireDate: return "No ExpireDate"
    }
  }
}
