//
//  PlaceModel+Extension.swift
//

import Foundation
import Sweet

extension Sweet.PlaceModel {
  init(place: Place) {
    let decoder = JSONDecoder.twitter

    let geo = try! decoder.decodeIfExists(Sweet.GeoModel.self, from: place.geo)

    let type: Sweet.PlaceType? = place.type.map { Sweet.PlaceType(rawValue: $0)! }

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
      type: type,
      containedWithin: containedWithin ?? []
    )
  }
}
