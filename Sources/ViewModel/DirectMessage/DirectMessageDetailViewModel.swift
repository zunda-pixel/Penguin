//
//  DirectMessageDetailViewModel.swift
//

import Foundation
import Sweet

@MainActor class DirectMessageDetailViewModel: ObservableObject, Hashable {
  nonisolated static func == (lhs: DirectMessageDetailViewModel, rhs: DirectMessageDetailViewModel)
    -> Bool
  {
    lhs.userID == rhs.userID && lhs.participantID == rhs.participantID
  }

  nonisolated func hash(into hasher: inout Hasher) {
    hasher.combine(userID)
    hasher.combine(participantID)
  }

  let participantID: String
  let userID: String

  var paginationToken: String? = nil
  var allDirectMessages: [Sweet.DirectMessageModel] = []
  var allUsers: [Sweet.UserModel] = []
  var allMedias: [Sweet.MediaModel] = []

  var showDirectMessages: [Sweet.DirectMessageModel] {
    guard let timelines else { return [] }

    return timelines.map { id in
      allDirectMessages.first { $0.id == id }!
    }.sorted(by: \.createdAt!)
  }

  @Published var errorHandle: ErrorHandle?
  @Published var timelines: Set<String>?
  @Published var text = ""

  init(participantID: String, userID: String) {
    self.participantID = participantID
    self.userID = userID
  }

  func send() async {
    do {
      let message: Sweet.NewDirectMessage.Message = .init(text: text)

      let response = try await Sweet(userID: userID).postDirectMessage(
        participantID: participantID,
        message: message
      )

      let directMessage: Sweet.DirectMessageModel = .init(
        eventType: .messageCreate,
        id: response.eventID,
        text: message.text!,
        conversationID: response.conversationID,
        createdAt: .now,
        senderID: userID
      )

      allDirectMessages.append(directMessage)

      if timelines == nil {
        timelines = []
      }

      timelines!.insert(directMessage.id)

      text = ""
    } catch {
      errorHandle = ErrorHandle(error: error)
    }
  }

  func addResponse(_ response: Sweet.DirectMessagesResponse) {
    response.directMessages.forEach {
      allDirectMessages.appendOrUpdate($0)
    }

    response.users.forEach {
      allUsers.appendOrUpdate($0)
    }

    response.medias.forEach {
      allMedias.appendOrUpdate($0)
    }
  }

  func addTimeline(ids: [String]) {
    if timelines == nil { timelines = [] }

    ids.forEach { timelines!.insert($0) }
  }

  func cellViewModel(directMessage: Sweet.DirectMessageModel, isBeforeElementSame: Bool)
    -> DirectMessageCellViewModel
  {
    let user = allUsers.first { $0.id == directMessage.senderID! }!

    let medias = allMedias.filter {
      directMessage.attachments?.mediaKeys.contains($0.id) ?? false
    }

    return .init(
      userID: userID, directMessage: directMessage, user: user, medias: medias,
      isBeforeElementSame: isBeforeElementSame)
  }

  func fetchDirectMessages() async {
    do {
      let response = try await Sweet(userID: userID).directMessageConversations(
        participantID: participantID,
        paginationToken: paginationToken
      )

      addResponse(response)

      addTimeline(ids: response.directMessages.map(\.id))

      self.paginationToken = response.meta?.nextToken

      if self.timelines == nil {
        self.timelines = []
      }

      response.directMessages.forEach {
        timelines?.insert($0.id)
      }
    } catch {
      errorHandle = ErrorHandle(error: error)
    }
  }
}
