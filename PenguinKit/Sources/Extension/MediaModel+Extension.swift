//
//  MediaModel+Extension.swift
//

import CoreGraphics
import Foundation
import Sweet

extension Sweet.MediaModel {
  init(media: Media) {
    let size = CGSize(width: media.width, height: media.height)
    
    let type: Sweet.MediaType = .init(rawValue: media.type!)!

    let decoder = JSONDecoder.twitter

    let variants = try! decoder.decode([Sweet.MediaVariant].self, from: media.variants!)

    let metrics = try! decoder.decodeIfExists(
      Sweet.MediaPublicMetrics.self,
      from: media.metrics
    )

    let durationMicroSeconds = Int(media.durationMicroSeconds)

    let privateMetrics = try! decoder.decodeIfExists(
      Sweet.MediaPrivateMetrics.self,
      from: media.privateMetrics
    )

    let promotedMetrics = try! decoder.decodeIfExists(
      Sweet.MediaPromotedMetrics.self,
      from: media.promotedMetrics
    )

    let organicMetrics = try! decoder.decodeIfExists(
      Sweet.MediaOrganicMetrics.self,
      from: media.organicMetrics
    )

    self.init(
      key: media.key!,
      type: type,
      size: size,
      previewImageURL: media.previewImageURL,
      url: media.url,
      variants: variants,
      durationMicroSeconds: durationMicroSeconds,
      alternateText: media.alternateText,
      metrics: metrics,
      privateMetrics: privateMetrics,
      promotedMetrics: promotedMetrics,
      organicMetrics: organicMetrics
    )
  }
}
