//
//  OneUnitDurationFormat+Extension.swift
//

import Foundation

extension FormatStyle where Self == OneUnitDurationFormat {
  static var twitter: OneUnitDurationFormat {
    return .init(
      candidates: [.day, .hour, .minute, .second],
      style: .brief
    )
  }
}

struct OneUnitDurationFormat: FormatStyle {
  typealias FormatInput = Range<Date>
  typealias FormatOutput = String

  var candidates: [Date.ComponentsFormatStyle.Field]
  var style: DateComponentsFormatter.UnitsStyle
  var calendar: Calendar = .current

  func format(_ value: FormatInput) -> FormatOutput {
    calendar.duration(from: value, candidates: candidates, style: style)!
  }

  func locale(_ locale: Locale) -> Self {
    var newValue = self
    newValue.calendar.locale = locale
    return newValue
  }
}

extension DateComponentsFormatter.UnitsStyle: Codable {
}
