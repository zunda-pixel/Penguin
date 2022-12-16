//
//  MoviePlayer.swift
//

import AVKit
import SwiftUI

#if os(macOS)
  private typealias Representable = NSViewRepresentable
#else
  private typealias Representable = UIViewControllerRepresentable
#endif

struct MoviePlayer: Representable {
  let player: AVPlayer

  #if os(macOS)
    func makeNSView(context: Context) -> some NSView {
      let view = AVPlayerView()
      view.player = player
      return view
    }

    func updateNSView(_ nsView: NSViewType, context: Context) {
    }

  #else
    func makeUIViewController(context: Context) -> some UIViewController {
      let view = AVPlayerViewController()
      view.player = player
      return view
    }

    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
    }
  #endif
}
