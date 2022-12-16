//
//  TwitterError.swift
//

import Sweet
import Foundation

extension Sweet.TwitterError: RecoverableError {
  public func attemptRecovery(optionIndex recoveryOptionIndex: Int) -> Bool {
    recoveryOptionIndex == 0
  }
  
  public var recoveryOptions: [String] {
    return ["OK"]
  }
}

extension Sweet.TwitterError: LocalizedError {
  public var errorDescription: String? {
    switch self {
    case .tooManyAccess: return "Too Many Access"
    case .accountLocked: return "Account is  Locked"
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
    case .unAuthorized: return "Authorization Error"
    case .unsupportedAuthentication: return "UnSupported Authorization"
    case .forbidden: return "Unknown Error"
    case .invalidRequest: return "Unknown Error"
    case .unknown: return "Unknown Error"
    }
  }
  
  public var recoverySuggestion: String? {
    let contactWithDeveloper = "Please Contact with Developer"
    
    switch self {
    case .tooManyAccess: return "Please access later"
    case .accountLocked: return "Please log in to https://twitter.com to unlock your account."
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
    case .unAuthorized: return "Please ReLogin"
    case .uploadCompliance: return contactWithDeveloper
    case .unsupportedAuthentication: return contactWithDeveloper
    case .forbidden: return contactWithDeveloper
    case .invalidRequest: return contactWithDeveloper
    case .unknown: return contactWithDeveloper
    }
  }
}
