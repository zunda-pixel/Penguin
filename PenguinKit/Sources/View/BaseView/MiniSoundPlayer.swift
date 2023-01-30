//
//  MiniSoundPlayer.swift
//

import AVFAudio
import Sweet
import SwiftUI
import UserNotificationsUI

class SoundPlayerViewModel: ObservableObject {
  let url: URL

  let durationMicroSeconds: Int
  var player: AVAudioPlayer?

  @Published var label: String = "play"

  init(url: URL, durationMicroSeconds: Int) {
    self.url = url
    self.durationMicroSeconds = durationMicroSeconds
  }

  func fetchVoice() async {
    do {
      let (data, _) = try await URLSession.shared.data(for: .init(url: url))
      self.player = try .init(data: data)
    } catch {
      let errorHandle = ErrorHandle(error: error)
      errorHandle.log()
    }
  }

  @MainActor
  func buttonClick() async {
    if player == nil {
      await fetchVoice()
    }

    if player?.isPlaying == true {
      player?.stop()
    } else {
      player?.play()
    }

    label = player?.isPlaying == true ? "pause" : "play"
  }

  func duration() -> String {
    let currentTime: TimeInterval = {
      if let player {
        return player.duration - player.currentTime
      } else {
        return TimeInterval(durationMicroSeconds)
      }
    }()

    return "\(ceil(currentTime))"
  }
}

struct MiniSoundPlayer: View {
  @StateObject var viewModel: SoundPlayerViewModel

  var body: some View {
    HStack {
      Button {
        Task {
          await viewModel.buttonClick()
        }
      } label: {
        Image(systemName: viewModel.label)
      }

      TimelineView(.periodic(from: .now, by: 1)) { _ in
        Text(viewModel.duration())
      }
    }
    .task {
      await viewModel.fetchVoice()
    }
  }
}

struct MiniSoundPlayer_Preview: PreviewProvider {
  static var previews: some View {
    MiniSoundPlayer(
      viewModel: .init(
        url: .init(
          string:
            "https://video.twimg.com/dm_video/1591388494718717953/vid/1280x720/Emjm-m0iDYwfwVTwEtXgYOA-iRq08QpyzU8oxRC1eg4.mp4?tag=1"
        )!, durationMicroSeconds: 4)
    )
    .padding()
    .border(.red)

  }
}
