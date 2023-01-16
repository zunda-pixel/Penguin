//
// Binding+Extension.swift
//

import SwiftUI

extension Binding {
  init?(unwrapping binding: Binding<Value?>) {
    guard let wrappedValue = binding.wrappedValue else { return nil }
    self.init(
      get: { wrappedValue },
      set: { binding.wrappedValue = $0 }
    )
  }

  init<T>(value: T, set: @escaping (T) -> Void) where Value == T? {
    self.init(get: { value }) { newValue in
      if let newValue {
        set(newValue)
      }
    }
  }

  func isPresented<Wrapped>() -> Binding<Bool> where Value == Wrapped? {
    .init(
      get: { self.wrappedValue != nil },
      set: { isPresented in
        if isPresented {
          self.wrappedValue = nil
        }
      }
    )
  }
}
