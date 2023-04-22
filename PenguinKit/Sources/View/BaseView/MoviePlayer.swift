//
//  MoviePlayer.swift
//

import AVKit
import SwiftUI

struct MoviePlayer: View {
  @Environment(\.dismiss) var dismiss

  let url: URL

  var body: some View {
    let player = AVPlayer(url: url)
    VideoPlayer(player: player)
      .overlay(alignment: .topLeading) {
        Button {
          dismiss()
        } label: {
          Label("Close", systemImage: "xmark")
            .labelStyle(.iconOnly)
        }
        .tint(.white)
        .bold()
        .padding(.top, 75)
        .padding(.leading, 30)
      }
      .onReceive(player.publisher(for: \.status)) { status in
        if status == .readyToPlay {
          player.play()
        }
      }
  }
}
