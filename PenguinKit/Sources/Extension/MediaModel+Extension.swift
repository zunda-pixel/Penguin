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
  
  func dictionaryValue() -> [String: Any] {
    let encoder = JSONEncoder.twitter
    
    let dictionary: [String: Any?] = [
      "key": key,
      "type": type.rawValue,
      "height": size?.height,
      "width": size?.width,
      "previewImageURL": previewImageURL,
      "url": url,
      "variants": try! encoder.encodeIfExists(variants),
      "durationMicroSeconds": durationMicroSeconds,
      "alternateText": alternateText,
      "metrics": try! encoder.encodeIfExists(metrics),
      "privateMetrics": try! encoder.encodeIfExists(privateMetrics),
      "promotedMetrics": try! encoder.encodeIfExists(promotedMetrics),
      "organicMetrics": try! encoder.encodeIfExists(organicMetrics),
    ]
    
    return dictionary.compactMapValues { $0 }
  }
}
