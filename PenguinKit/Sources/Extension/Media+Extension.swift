//
//  Media+Extension.swift
//

import Foundation
import Sweet

extension Media {
  func setMediaModel(_ media: Sweet.MediaModel) {
    self.key = media.key
    
    if let width = media.size?.width {
      self.width = width
    }
    
    if let height = media.size?.height {
      self.height = height
    }
    
    self.url = media.url
    self.previewImageURL = media.previewImageURL
    self.type = media.type.rawValue

    let encoder = JSONEncoder.twitter
    self.variants = try! encoder.encode(media.variants)

    if let durationMicroSeconds = media.durationMicroSeconds {
      self.durationMicroSeconds = Int32(durationMicroSeconds)
    }

    self.alternateText = media.alternateText
    self.metrics = try! encoder.encodeIfExists(media.metrics)
    self.privateMetrics = try! encoder.encodeIfExists(media.privateMetrics)
    self.promotedMetrics = try! encoder.encodeIfExists(media.promotedMetrics)
    self.organicMetrics = try! encoder.encodeIfExists(media.organicMetrics)
  }
}
