//
//  DirectMessageCell.swift
//

import ChatBubble
import SwiftUI

struct DirectMessageCell: View {
  @ObservedObject var viewModel: DirectMessageCellViewModel
  @Environment(\.settings) var settings

  var isOwned: Bool {
    viewModel.userID == viewModel.user.id
  }

  var dateView: some View {
    Text(viewModel.directMessage.createdAt!, style: .time)
      .font(.caption2)
  }

  @ViewBuilder
  var chatText: some View {
    let position: ChatBubble.TailPosition = isOwned ? .trailingBottom : .leadingBottom

    Text(viewModel.directMessage.text)
      .fixedSize(horizontal: false, vertical: true)
      .padding(.horizontal, 10)
      .padding(.vertical, 7)
      .frame(minWidth: 40)
      .background {
        let cornerRadius: CGFloat = 17

        Group {
          if viewModel.isBeforeElementSame {
            RoundedRectangle(cornerRadius: cornerRadius)
          } else {
            ChatBubble(cornerRadius: cornerRadius)
              .rotateChatBubble(position: position)
          }
        }
        .foregroundColor(settings.colorType.colorSet.tintColor.opacity(0.5))

      }
  }

  var body: some View {
    VStack {
      HStack(alignment: .bottom) {
        if isOwned {
          dateView

          chatText
        } else {
          ProfileImageView(url: viewModel.user.profileImageURL!)
            .frame(width: 40, height: 40)

          chatText

          dateView
        }
      }

      let videos = viewModel.medias.filter { $0.type == .video }

      let video = videos.flatMap(\.variants).max { $0.bitRate ?? 0 < $1.bitRate ?? 0 }

      if let video {
        Text("Video \(video.url)")

        MiniSoundPlayer(
          viewModel: .init(
            url: video.url, durationMicroSeconds: videos.first!.durationMicroSeconds!))
      }
    }
  }
}

struct DirectMessageCell_Preview: PreviewProvider {
  struct Preview: View {
    var body: some View {
      let viewModel = DirectMessageCellViewModel(
        userID: "1320987198275",
        directMessage: .init(
          eventType: .messageCreate,
          id: UUID().uuidString,
          text: "H",
          conversationID: "1320987198275",
          createdAt: .now.addingTimeInterval(-123456),
          senderID: "1320987198275"
        ),
        user: .init(
          id: "13209871798275",
          name: "test_user",
          userName: "test_user",
          profileImageURL: .init(
            string: "https://pbs.twimg.com/profile_images/974322170309390336/tY8HZIhk_400x400.jpg"
          )!
        ),
        medias: [],
        isBeforeElementSame: false
      )

      DirectMessageCell(viewModel: viewModel)
    }
  }

  static var previews: some View {
    Preview()
      .frame(height: 50)
  }
}
