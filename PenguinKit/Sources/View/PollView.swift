//
//  PollView.swift
//

import Sweet
import SwiftUI

struct PollView: View {
  let poll: Sweet.PollModel

  var totalVote: Int {
    poll.options.reduce(0) { $0 + $1.votes }
  }

  func percent(value: Double) -> Int {
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
            let value: Double = totalVote == 0 ? 0.1 : Double(option.votes)
            let total: Double = totalVote == 0 ? 3 : Double(totalVote)

            ProgressView(value: value, total: total) {
              Text(option.label)
                .lineLimit(1)
            }
            let percent = percent(value: Double(option.votes))
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
        .init(position: 1, label: "mikan mikan mikan mikan mikan mikan mikan", votes: 189),
        .init(position: 2, label: "apple", votes: 232),
        .init(position: 3, label: "orange", votes: 102),
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
