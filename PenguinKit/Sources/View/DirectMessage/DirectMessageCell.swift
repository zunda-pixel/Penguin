//
//  DirectMessageCell.swift
//

import ChatBubble
import SwiftUI

struct DirectMessageCell: View {
  @StateObject var viewModel: DirectMessageCellViewModel
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

  @ViewBuilder
  var mediaPlayer: some View {
    let videos = viewModel.medias.filter { $0.type == .video }

    let video = videos.flatMap(\.variants).max { $0.bitRate ?? 0 < $1.bitRate ?? 0 }

    if let video {
      let rectangle = RoundedRectangle(cornerSize: .init(width: 10, height: 10))

      MiniSoundPlayer(
        viewModel: .init(
          url: video.url,
          durationMicroSeconds: videos.first!.durationMicroSeconds!
        )
      )
      .textSelection(.enabled)
      .frame(minWidth: 80)
      .foregroundColor(.white)
      .tint(.white)
      .padding(10)
      .background(settings.colorType.colorSet.tintColor)
      .clipShape(rectangle)
    }
  }

  var body: some View {
    HStack(alignment: .top) {
      if isOwned {
        VStack(alignment: .trailing) {
          HStack(alignment: .bottom) {
            dateView
            chatText
          }
          mediaPlayer
        }
      } else {
        ProfileImageView(url: viewModel.user.profileImageURL!)
          .frame(width: 40, height: 40)

        VStack(alignment: .leading) {
          HStack(alignment: .bottom) {
            chatText
            dateView
          }

          mediaPlayer
        }
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
        medias: [
          .init(
            key: "key",
            type: .video,
            variants: [
              .init(
                bitRate: 1,
                contentType: .mp4,
                url: URL(
                  string:
                    "https://video.twimg.com/dm_video/1591388494718717953/vid/1280x720/Emjm-m0iDYwfwVTwEtXgYOA-iRq08QpyzU8oxRC1eg4.mp4?tag=1"
                )!
              )
            ],
            durationMicroSeconds: 10
          )
        ],
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
