//
//  LivePhotoView.swift
//

import PhotosUI
import SwiftUI

#if os(macOS)
  typealias ViewRepresentable = NSViewRepresentable
  typealias ViewControllerRepresentable = NSViewControllerRepresentable
#else
  typealias ViewRepresentable = UIViewRepresentable
  typealias ViewControllerRepresentable = UIViewControllerRepresentable
#endif

struct LivePhotoView: ViewRepresentable {
  let livePhoto: PHLivePhoto

  #if os(macOS)
    func makeNSView(context: Context) -> some NSView {
      let livePhotoView = PHLivePhotoView(frame: .zero)
      livePhotoView.livePhoto = livePhoto
      return livePhotoView
    }

    func updateNSView(_ nsView: NSViewType, context: Context) {
    }

  #else
    func makeUIView(context: Context) -> PHLivePhotoView {
      let livePhotoView = PHLivePhotoView(frame: .zero)
      livePhotoView.livePhoto = livePhoto
      return livePhotoView
    }

    func updateUIView(_ livePhotoView: PHLivePhotoView, context: Context) {
    }
  #endif
}
