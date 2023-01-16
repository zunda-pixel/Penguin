//
//  Place+Extension.swift
//

import Foundation
import Sweet

extension Place {
  func setPlaceModel(_ place: Sweet.PlaceModel) {
    self.id = place.id
    self.fullName = place.fullName
    self.name = place.name
    self.country = place.country
    self.countryCode = place.countryCode

    let encoder = JSONEncoder.twitter
    self.geo = try! encoder.encodeIfExists(place.geo)
    self.type = place.type?.rawValue
    self.containedWithin = try! encoder.encode(place.containedWithin)
  }
}
