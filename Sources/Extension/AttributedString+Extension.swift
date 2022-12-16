//
// AttributedString+Extension.swift
//

import Foundation

extension AttributedStringProtocol {
  @MainActor func ranges<T>(
    of pattern: T,
    options: String.CompareOptions = [],
    locale: Locale? = nil
  )
    -> [Range<AttributedString.Index>] where T: StringProtocol
  {
    guard let range = self.range(of: pattern, options: options, locale: locale) else {
      return []
    }

    let remaining = self[range.upperBound...]
    return [range] + remaining.ranges(of: pattern, options: options, locale: locale)
  }
}
