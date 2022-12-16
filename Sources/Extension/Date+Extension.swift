//
//  Date+Extension.swift
//

import Foundation

extension Calendar {
  func duration(
    from range: Range<Date>,
    candidates components: [Date.ComponentsFormatStyle.Field],
    style: DateComponentsFormatter.UnitsStyle
  ) -> String? {
    let formatter = DateComponentsFormatter()
    formatter.unitsStyle = style
    formatter.calendar = self

    for component in components.map(\.component) {
      let dateComponents = self.dateComponents(
        [component],
        from: range.lowerBound,
        to: range.upperBound
      )

      guard let time = dateComponents.time(from: component), time != 0 else { continue }

      formatter.allowedUnits = component.unit

      guard let dateString = formatter.string(from: dateComponents) else { continue }

      return dateString
    }

    return nil
  }
}

extension Date.ComponentsFormatStyle.Field {
  var component: Calendar.Component {
    switch self {
    case .second: return .second
    case .minute: return .minute
    case .hour: return .hour
    case .day: return .day
    case .week: return .weekOfMonth
    case .month: return .month
    case .year: return .year
    default:
      fatalError()
    }
  }
}

extension Calendar.Component {
  var unit: NSCalendar.Unit {
    switch self {
    case .second: return .second
    case .era: return .era
    case .year: return .year
    case .month: return .month
    case .day: return .day
    case .hour: return .hour
    case .minute: return .minute
    case .weekday: return .weekday
    case .weekdayOrdinal: return .weekdayOrdinal
    case .quarter: return .quarter
    case .weekOfMonth: return .weekOfMonth
    case .weekOfYear: return .weekOfYear
    case .yearForWeekOfYear: return .yearForWeekOfYear
    case .nanosecond: return .nanosecond
    case .calendar: return .calendar
    case .timeZone: return .timeZone
    @unknown default:
      fatalError()
    }
  }
}

extension DateComponents {
  func time(from component: Calendar.Component) -> Int? {
    switch component {
    case .second: return second
    case .era: return era
    case .year: return year
    case .month: return month
    case .day: return day
    case .hour: return hour
    case .minute: return minute
    case .weekday: return weekday
    case .weekdayOrdinal: return weekdayOrdinal
    case .quarter: return quarter
    case .weekOfMonth: return weekOfMonth
    case .weekOfYear: return weekOfYear
    case .yearForWeekOfYear: return yearForWeekOfYear
    case .nanosecond: return nanosecond
    default:
      fatalError()
    }
  }
}
