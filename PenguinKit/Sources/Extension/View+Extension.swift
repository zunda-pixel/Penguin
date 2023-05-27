//
//  View+Extension.swift
//

import SwiftUI

extension View {
  @ViewBuilder
  func ifLet<Content: View, Value>(_ optional: Value?, transform: (Self, Value) -> Content)
    -> some View
  {
    if let optional {
      transform(self, optional)
    } else {
      self
    }
  }

  @ViewBuilder
  func `if`<Content: View>(_ conditional: Bool, transform: (Self) -> Content) -> some View {
    if conditional {
      transform(self)
    } else {
      self
    }
  }

  @ViewBuilder
  func ifElse<IfContent: View, ElseContent: View>(
    _ conditional: Bool,
    ifTransform: (Self) -> IfContent,
    elseTransform: (Self) -> ElseContent
  ) -> some View {
    if conditional {
      ifTransform(self)
    } else {
      elseTransform(self)
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
        #if DEBUG
          #if os(macOS)
            NSPasteboard.general.setString(errorHandle.logMessage, forType: .string)
          #else
            UIPasteboard.general.string = errorHandle.logMessage
          #endif
        #endif
      }
    }
  }

  func navigationBarTitleDisplayModeIfAvailable(_ displayMode: NavigationBarItem.TitleDisplayMode)
    -> some View
  {
    #if os(macOS)
      self
    #else
      self.navigationBarTitleDisplayMode(displayMode)
    #endif
  }
}

#if os(macOS)
  enum NavigationBarItem {
    enum TitleDisplayMode {
      case inline
      case large
    }
  }
#endif
