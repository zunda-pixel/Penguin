//
//  GeneralModifier.swift
//

import SwiftUI

extension View {
  func scrollViewAttitude() -> some View {
    #if os(macOS)
    self
    #else
    self.modifier(ScrollViewAttitude())
    #endif
  }

  func scrollContentAttribute() -> some View {
    #if os(macOS)
    self
    #else
    self.modifier(ScrollContentAttribute())
    #endif
  }

  func listContentAttribute() -> some View {
    #if os(macOS)
    self
    #else
    self.modifier(ListContentAttribute())
    #endif
  }

  func navigationBarAttribute() -> some View {
    #if os(macOS)
    self
    #else
    self.modifier(NavigationBarAttribute())
    #endif
  }
}

struct ScrollViewAttitude: ViewModifier {
  @Environment(\.settings) var settings
  @Environment(\.colorScheme) var colorScheme

  func body(content: Content) -> some View {
    content
      .scrollContentBackground(.hidden)
      .background(
        colorScheme == .dark
          ? settings.colorType.colorSet.darkSecondaryColor
          : settings.colorType.colorSet.lightSecondaryColor)
  }
}

struct ScrollContentAttribute: ViewModifier {
  @Environment(\.settings) var settings
  @Environment(\.colorScheme) var colorScheme

  func body(content: Content) -> some View {
    content
      .background(
        colorScheme == .dark
          ? settings.colorType.colorSet.darkPrimaryColor
          : settings.colorType.colorSet.lightPrimaryColor)
  }
}

struct ListContentAttribute: ViewModifier {
  @Environment(\.settings) var settings
  @Environment(\.colorScheme) var colorScheme

  func body(content: Content) -> some View {
    content
      .listRowBackground(
        colorScheme == .dark
          ? settings.colorType.colorSet.darkPrimaryColor
          : settings.colorType.colorSet.lightPrimaryColor)
  }
}


#if !os(macOS)
struct NavigationBarAttribute: ViewModifier {
  @Environment(\.settings) var settings
  @Environment(\.colorScheme) var colorScheme

  func body(content: Content) -> some View {
    content
      .toolbarBackground(
        colorScheme == .dark
          ? settings.colorType.colorSet.darkPrimaryColor
          : settings.colorType.colorSet.lightPrimaryColor, for: .navigationBar
      )
      .toolbarBackground(.visible, for: .navigationBar)
  }
}
#endif
