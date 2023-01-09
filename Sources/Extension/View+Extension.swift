//
//  View+Extension.swift
//

import SwiftUI

extension View {
  @ViewBuilder
  func `if`<T: View>(_ conditional: Bool, transform: (Self) -> T) -> some View {
    if conditional {
      transform(self)
    } else {
      self
    }
  }

  func sheet<Value, Content>(
    unwrapping optionalValue: Binding<Value?>,
    @ViewBuilder content: @escaping (Binding<Value>) -> Content
  ) -> some View where Value: Identifiable, Content: View {
    self.sheet(item: optionalValue) { _ in
      if let bindingValue = Binding(unwrapping: optionalValue) {
        content(bindingValue)
      }
    }
  }

  func alert<A: View, M: View, T>(
    presenting data: Binding<T?>,
    title: (T) -> Text,
    @ViewBuilder message: @escaping (T) -> M,
    @ViewBuilder actions: @escaping (T) -> A
  ) -> some View {
    self.alert(
      data.wrappedValue.map(title) ?? Text(""),
      isPresented: data.isPresented(),
      presenting: data.wrappedValue,
      actions: actions,
      message: message
    )
  }
  
  func alert(errorHandle: Binding<ErrorHandle?>) -> some View {
    self.alert(presenting: errorHandle) { errorHandle in
      Text(errorHandle.title)
    } message: { errorHandle in
      Text(errorHandle.message)
    } actions: { errorHandle in
      Button("OK") {
        UIPasteboard.general.string = errorHandle.logMessage
      }
    }
  }
}
