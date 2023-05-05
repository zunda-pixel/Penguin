//
//  CreateTweetViewModel.swift
//

import Photos
import PhotosUI
import Sweet
import SwiftUI

@MainActor protocol NewTweetViewProtocol: ObservableObject {
  var userID: String { get set }
  var text: String { get set }
  var selectedReplySetting: Sweet.ReplySetting { get set }
  var poll: Sweet.PostPollModel? { get set }
  var photos: [Photo] { get set }
  var photosPickerItems: [PhotosPickerItem] { get set }
  var errorHandle: ErrorHandle? { get set }
  var disableTweetButton: Bool { get }
  var leftTweetCount: Int { get }
  var quoted: TweetContentModel? { get }
  var placeHolder: String { get }
  var reply: Reply? { get }
  var selectedUserID: Set<String> { get set }
  var isPresentedSelectUserView: Bool { get set }
  var title: String { get }
  func postTweet() async
  func loadPhotos(with pickers: [PhotosPickerItem]) async
  func pollButtonAction()
}

@MainActor final class NewTweetViewModel: NewTweetViewProtocol {
  let quoted: TweetContentModel?
  let reply: Reply?
  let title: String

  @Published var selectedUserID: Set<String>
  @Published var isPresentedSelectUserView: Bool
  @Published var text: String
  @Published var selectedReplySetting: Sweet.ReplySetting
  @Published var poll: Sweet.PostPollModel?
  @Published var photos: [Photo]
  @Published var photosPickerItems: [PhotosPickerItem]
  @Published var userID: String
  @Published var errorHandle: ErrorHandle?

  convenience init(userID: String) {
    self.init(userID: userID, quoted: nil, reply: nil, title: "New Tweet")
  }

  convenience init(userID: String, reply: Reply?) {
    self.init(userID: userID, quoted: nil, reply: reply, title: "Reply Tweet")
  }

  convenience init(userID: String, quoted: TweetContentModel?) {
    self.init(userID: userID, quoted: quoted, reply: nil, title: "Quote Tweet")
  }

  private init(userID: String, quoted: TweetContentModel?, reply: Reply?, title: String) {
    self.userID = userID
    self.quoted = quoted
    self.reply = reply
    self.title = title

    self.selectedUserID = Set(reply?.replyUsers.map(\.id) ?? [])

    self.isPresentedSelectUserView = false
    self.text = ""
    self.selectedReplySetting = .everyone
    self.photos = []
    self.photosPickerItems = []
  }

  var placeHolder: String {
    if text.isEmpty {
      return quoted == nil ? " Say something..." : " Add Comment..."
    } else {
      return ""
    }
  }

  var disableTweetButton: Bool {
    if let poll {
      for option in poll.options {
        if option.count < 1 {
          return true
        }
      }
    }

    if text.count > 280 {
      return true
    }

    if photos.count > 1 {
      return false
    }

    if text.count < 1 {
      return true
    }

    return false
  }

  func postTweet() async {
    let replySetting: Sweet.ReplyModel?

    if let reply {
      let excludeReplyUserIDs = Set(reply.replyUsers.map(\.id)).subtracting(selectedUserID)
      replySetting = Sweet.ReplyModel(
        replyToTweetID: reply.tweetContent.tweet.id, excludeReplyUserIDs: Array(excludeReplyUserIDs))
    } else {
      replySetting = nil
    }

    let tweet = Sweet.PostTweetModel(
      text: text,
      directMessageDeepLink: nil,
      forSuperFollowersOnly: false,
      geo: nil,
      media: nil,
      poll: poll,
      quoteTweetID: quoted?.tweet.id,
      reply: replySetting,
      replySettings: selectedReplySetting
    )

    do {
      _ = try await Sweet(userID: userID).createTweet(tweet)
    } catch {
      let errorHandle = ErrorHandle(error: error)
      errorHandle.log()
      self.errorHandle = errorHandle
    }
  }

  var leftTweetCount: Int {
    return 280 - text.count
  }

  @MainActor func loadPhotos(with pickers: [PhotosPickerItem]) async {
    let oldPhotos = photos
    var newPhotos: [Photo] = []

    do {
      for picker in pickers {
        if let foundPhoto = oldPhotos.first(where: { $0.id == picker.itemIdentifier }) {
          newPhotos.append(foundPhoto)
        } else {
          let item = try await picker.loadPhoto()
          let newPhoto = Photo(id: picker.itemIdentifier, item: item)
          newPhotos.append(newPhoto)
        }

        photos = newPhotos
      }

      photos = newPhotos
    } catch {
      let errorHandle = ErrorHandle(error: error)
      errorHandle.log()
      self.errorHandle = errorHandle
    }
  }

  func pollButtonAction() {
    if poll?.options == nil || poll!.options.count < 2 {
      poll = .init(options: ["", ""], durationMinutes: 10)
    } else {
      poll = nil
    }
  }
}
