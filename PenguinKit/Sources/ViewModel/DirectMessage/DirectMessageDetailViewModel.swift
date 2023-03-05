//
//  DirectMessageDetailViewModel.swift
//

import Foundation
import Sweet

@MainActor final class DirectMessageDetailViewModel: ObservableObject, Hashable {
  let participantID: String
  let userID: String

  var paginationToken: String?
  var allDirectMessages: Set<Sweet.DirectMessageModel>
  var allUsers: Set<Sweet.UserModel>
  var allMedias: Set<Sweet.MediaModel>

  var showDirectMessages: [Sweet.DirectMessageModel] {
    guard let timelines else { return [] }

    return timelines.map { id in
      allDirectMessages.first { $0.id == id }!
    }.sorted(by: \.createdAt!)
  }

  @Published var errorHandle: ErrorHandle?
  @Published var timelines: Set<String>?
  @Published var text: String

  init(participantID: String, userID: String) {
    self.participantID = participantID
    self.userID = userID
    self.text = ""
    self.allDirectMessages = []
    self.allUsers = []
    self.allMedias = []
  }

  nonisolated static func == (lhs: DirectMessageDetailViewModel, rhs: DirectMessageDetailViewModel)
    -> Bool
  {
    lhs.userID == rhs.userID && lhs.participantID == rhs.participantID
  }

  nonisolated func hash(into hasher: inout Hasher) {
    hasher.combine(userID)
    hasher.combine(participantID)
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

      allDirectMessages.insert(directMessage)

      if timelines == nil {
        timelines = []
      }

      timelines!.insert(directMessage.id)

      text = ""
    } catch {
      let errorHandle = ErrorHandle(error: error)
      errorHandle.log()
      self.errorHandle = errorHandle
    }
  }

  func addResponse(_ response: Sweet.DirectMessagesResponse) {
    response.directMessages.forEach {
      allDirectMessages.insertOrUpdate($0, by: \.id)
    }

    response.users.forEach {
      allUsers.insertOrUpdate($0, by: \.id)
    }

    response.medias.forEach {
      allMedias.insertOrUpdate($0, by: \.id)
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
      userID: userID,
      directMessage: directMessage,
      user: user, medias: medias,
      isBeforeElementSame: isBeforeElementSame
    )
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
      let errorHandle = ErrorHandle(error: error)
      errorHandle.log()
      self.errorHandle = errorHandle
    }
  }
}
