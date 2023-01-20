//
//  Array+Extension.swift
//

import Foundation

extension Array {
  subscript(safe index: Index) -> Element? {
    return indices.contains(index) ? self[index] : nil
  }
}

extension Array where Element: Equatable {
  mutating func appendOrUpdate(_ element: Element) {
    if let index = self.firstIndex(of: element) {
      self[index] = element
    } else {
      self.append(element)
    }
  }
}

extension RangeReplaceableCollection where Element: Equatable {
  mutating func appendIfNotContains(_ element: Element) {
    if !contains(element) {
      append(element)
    }
  }
}

@resultBuilder
public struct ArrayBuilder<Element> {
  public static func buildPartialBlock(first: Element) -> [Element] { [first] }
  public static func buildPartialBlock(first: [Element]) -> [Element] { first }
  public static func buildPartialBlock(accumulated: [Element], next: Element) -> [Element] {
    accumulated + [next]
  }
  public static func buildPartialBlock(accumulated: [Element], next: [Element]) -> [Element] {
    accumulated + next
  }

  // Empty Case
  public static func buildBlock() -> [Element] { [] }
  // If/Else
  public static func buildEither(first: [Element]) -> [Element] { first }
  public static func buildEither(second: [Element]) -> [Element] { second }
  // Just ifs
  public static func buildIf(_ element: [Element]?) -> [Element] { element ?? [] }
  // fatalError()
  public static func buildPartialBlock(first: Never) -> [Element] {}
}

// MARK: - Array.init(builder:)
extension Array {
  public init(@ArrayBuilder<Element> builder: () -> [Element]) {
    self.init(builder())
  }
}

extension Sequence {
  func sorted<T: Comparable>(by keyPath: KeyPath<Element, T>, isAscending: Bool = true) -> [Element]
  {
    return sorted {
      let lhs = $0[keyPath: keyPath]
      let rhs = $1[keyPath: keyPath]
      return isAscending ? lhs < rhs : lhs > rhs
    }
  }
  
  func uniqued<T: Hashable>(by keyPath: KeyPath<Element, T>) -> [Element] {
    return uniqued { $0[keyPath: keyPath] }
  }
}

