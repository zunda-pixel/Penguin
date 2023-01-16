//
//  Poll+Extension.swift
//

import Foundation
import Sweet

extension Poll {
  func setPollModel(_ poll: Sweet.PollModel) throws {
    self.id = poll.id
    self.durationMinutes = Int32(poll.durationMinutes)
    self.votingStatus = poll.votingStatus.rawValue
    self.endDateTime = poll.endDateTime
    self.options = try JSONEncoder.twitter.encode(poll.options)
  }
}
