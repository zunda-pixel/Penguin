//
//  MoviePlayer.swift
//

import AVKit
import SwiftUI
import Combine

#if os(macOS)
  private typealias Representable = NSViewRepresentable
#else
  private typealias Representable = UIViewControllerRepresentable
#endif

struct MoviePlayer: Representable {
  let player: AVPlayer
  
  func makeCoordinator() -> Coordinator {
    Coordinator(parent: self)
  }
  
#if os(macOS)
  func makeNSView(context: Context) -> some NSView {
    player
      .publisher(for: \.status)
      .sink { context.coordinator.playMovie(status: $0) }
      .store(in: &context.coordinator.cancellable)
    
    let view = AVPlayerView()
    view.player = player
    return view
  }
  
  func updateNSView(_ nsView: NSViewType, context: Context) {
  }
  
#else
  func makeUIViewController(context: Context) -> some UIViewController {
    player
      .publisher(for: \.status)
      .sink { context.coordinator.playMovie(status: $0) }
      .store(in: &context.coordinator.cancellable)
    
    let view = AVPlayerViewController()
    view.player = player

    return view
  }
  
  func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
  }
#endif
  
  class Coordinator {
    let parent: MoviePlayer
    
    var cancellable = Set<AnyCancellable>()
    
    init(parent: MoviePlayer) {
      self.parent = parent
    }
    
    func playMovie(status: AVPlayer.Status) {
      guard status == .readyToPlay else { return }
      
      parent.player.play()
    }
  }
}
