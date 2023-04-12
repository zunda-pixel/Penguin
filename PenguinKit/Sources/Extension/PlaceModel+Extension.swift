//
//  PlaceModel+Extension.swift
//

import Foundation
import Sweet

extension Sweet.PlaceModel {
  init(place: Place) {
    let decoder = JSONDecoder.twitter

    let geo = try! decoder.decodeIfExists(Sweet.GeoModel.self, from: place.geo)

    let containedWithin = try! decoder.decodeIfExists(
      [String].self,
      from: place.containedWithin
    )

    self.init(
      id: place.id!,
      fullName: place.fullName!,
      name: place.name,
      country: place.country,
      countryCode: place.countryCode,
      geo: geo,
      type: place.type,
      containedWithin: containedWithin ?? []
    )
  }

  func dictionaryValue() -> [String: Any] {
    let encoder = JSONEncoder.twitter

    let dictionary: [String: Any?] = [
      "id": id,
      "fullName": fullName,
      "name": name,
      "country": country,
      "countryCode": countryCode,
      "geo": try! encoder.encodeIfExists(geo),
      "type": type,
      "containedWithin": try! encoder.encode(containedWithin),
    ]

    return dictionary.compactMapValues { $0 }
  }
}
