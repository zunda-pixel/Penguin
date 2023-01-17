//
//  CreateTweetViewModel.swift
//

@preconcurrency import CoreLocation
import Photos
import PhotosUI
import Sweet
import SwiftUI

typealias TweetAndUser = (tweet: Sweet.TweetModel, user: Sweet.UserModel)

@MainActor protocol NewTweetViewProtocol: NSObject, ObservableObject, CLLocationManagerDelegate {
  var userID: String { get set }
  var text: String { get set }
  var selectedReplySetting: Sweet.ReplySetting { get set }
  var locationString: String? { get set }
  var poll: Sweet.PostPollModel? { get set }
  var photos: [Photo] { get set }
  var photosPickerItems: [PhotosPickerItem] { get set }
  var errorHandle: ErrorHandle? { get set }
  var disableTweetButton: Bool { get }
  var locationManager: CLLocationManager { get }
  var leftTweetCount: Int { get }
  var loadingLocation: Bool { get set }
  var quoted: TweetAndUser? { get }
  var title: String { get }
  func postTweet() async throws
  func setLocation() async
  func loadPhotos(with pickers: [PhotosPickerItem]) async
  func pollButtonAction()
}

@MainActor final class NewTweetViewModel: NSObject, NewTweetViewProtocol {
  let quoted: TweetAndUser?

  var locationManager: CLLocationManager

  @Published var text: String
  @Published var selectedReplySetting: Sweet.ReplySetting
  @Published var locationString: String?
  @Published var poll: Sweet.PostPollModel?
  @Published var photos: [Photo]
  @Published var photosPickerItems: [PhotosPickerItem]
  @Published var loadingLocation: Bool
  @Published var userID: String
  @Published var errorHandle: ErrorHandle?

  init(userID: String, quoted: TweetAndUser? = nil) {
    self.userID = userID
    self.quoted = quoted

    self.text = ""
    self.selectedReplySetting = .everyone
    self.photos = []
    self.photosPickerItems = []
    self.loadingLocation = false
    self.locationManager = CLLocationManager()

    super.init()

    locationManager.delegate = self
  }

  var title: String {
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

  func postTweet() async throws {
    let tweet = Sweet.PostTweetModel(
      text: text,
      directMessageDeepLink: nil,
      forSuperFollowersOnly: false,
      geo: nil,
      media: nil,
      poll: poll,
      quoteTweetID: quoted?.tweet.id,
      reply: nil,
      replySettings: selectedReplySetting
    )

    _ = try await Sweet(userID: userID).createTweet(tweet)
  }

  var leftTweetCount: Int {
    return 280 - text.count
  }

  func setLocation() async {
    loadingLocation = true

    defer {
      loadingLocation = false
    }

    guard let location = locationManager.location else {
      return
    }

    do {
      let places = try await CLGeocoder().reverseGeocodeLocation(location)

      guard let place = places.first else {
        return
      }

      self.locationString = (place.locality ?? "") + (place.name ?? "")
    } catch {
      let errorHandle = ErrorHandle(error: error)
      errorHandle.log()
      self.errorHandle = errorHandle
    }
  }

  nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
    Task {
      await setLocation()
    }
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
