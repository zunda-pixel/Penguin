//
//  PollView.swift
//

import Sweet
import SwiftUI

struct PollView: View {
  let poll: Sweet.PollModel

  let totalVote: Int

  init(poll: Sweet.PollModel) {
    self.poll = poll

    self.totalVote = poll.options.reduce(0) { $0 + $1.votes }

  }

  func getPercent(value: Double) -> Int {
    if value == 0 {
      return 0
    }

    let percent = value / Double(totalVote) * 100.0

    return Int(percent)
  }

  var body: some View {
    VStack {
      Grid {
        ForEach(poll.options) { option in
          GridRow {
            ProgressView(
              value: Double(option.votes),
            ) {
              Text(option.label)
                .lineLimit(1)
            }
            let percent = getPercent(value: Double(option.votes))
            Text("\(percent)%")
          }
        }
      }

      HStack {
        Text("\(totalVote) Votes")
        Text("Poll \(poll.votingStatus.rawValue)")
      }
    }
  }
}

struct PollView_Previews: PreviewProvider {
  static var previews: some View {
    let poll: Sweet.PollModel = .init(
      id: "Hello",
      votingStatus: .isClosed,
      endDateTime: .now,
      durationMinutes: 12,
      options: [
        .init(position: 1, label: "mikan mikan mikan mikan mikan mikan mikan", votes: 0),
        .init(position: 2, label: "apple", votes: 34),
        .init(position: 3, label: "orange", votes: 21),
      ]
    )
    PollView(poll: poll)
      .padding()
      .overlay {
        RoundedRectangle(cornerRadius: 13)
          .stroke(.secondary, lineWidth: 1)
      }
      .padding()
  }
}
