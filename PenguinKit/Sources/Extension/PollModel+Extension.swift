//
//  PollModel+Extension.swift
//

import Foundation
import Sweet

extension Sweet.PollModel {
  init(poll: Poll) {
    let options = try? JSONDecoder.twitter.decodeIfExists([Sweet.PollItem].self, from: poll.options)

    let status: Sweet.PollStatus = .init(rawValue: poll.votingStatus!)!

    self.init(
      id: poll.id!,
      votingStatus: status,
      endDateTime: poll.endDateTime!,
      durationMinutes: Int(poll.durationMinutes),
      options: options ?? []
    )
  }

  func dictionaryValue() -> [String: Any] {
    let encoder = JSONEncoder.twitter

    let dictionary: [String: Any] = [
      "id": id,
      "votingStatus": votingStatus.rawValue,
      "endDateTime": endDateTime,
      "durationMinutes": durationMinutes,
      "options": try! encoder.encode(options),
    ]

    return dictionary
  }
}
