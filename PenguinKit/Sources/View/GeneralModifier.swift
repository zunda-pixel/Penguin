//
//  GeneralModifier.swift
//

import SwiftUI

extension View {
  func scrollViewAttitude() -> some View {
    self.modifier(ScrollViewAttitude())
  }
  
  func scrollContentAttribute() -> some View {
    self.modifier(ScrollContentAttribute())
  }
  
  func listContentAttribute() -> some View {
    self.modifier(ListContentAttribute())
  }
  
  func navigationBarAttribute() -> some View {
    self.modifier(NavigationBarAttribute())
  }
}

struct ScrollViewAttitude: ViewModifier {
  @Environment(\.settings) var settings
  @Environment(\.colorScheme) var colorScheme
  
  func body(content: Content) -> some View {
    content
      .scrollContentBackground(.hidden)
      .background(colorScheme == .dark ? settings.colorType.colorSet.darkSecondaryColor : settings.colorType.colorSet.lightSecondaryColor)
  }
}

struct ScrollContentAttribute: ViewModifier {
  @Environment(\.settings) var settings
  @Environment(\.colorScheme) var colorScheme
  
  func body(content: Content) -> some View {
    content
      .background(colorScheme == .dark ? settings.colorType.colorSet.darkPrimaryColor : settings.colorType.colorSet.lightPrimaryColor)
  }
}

struct ListContentAttribute: ViewModifier {
  @Environment(\.settings) var settings
  @Environment(\.colorScheme) var colorScheme
  
  func body(content: Content) -> some View {
    content
      .listRowBackground(colorScheme == .dark ? settings.colorType.colorSet.darkPrimaryColor : settings.colorType.colorSet.lightPrimaryColor)
  }
}

struct NavigationBarAttribute: ViewModifier {
  @Environment(\.settings) var settings
  @Environment(\.colorScheme) var colorScheme
  
  func body(content: Content) -> some View {
    content
      .toolbarBackground(colorScheme == .dark ? settings.colorType.colorSet.darkPrimaryColor : settings.colorType.colorSet.lightPrimaryColor, for: .navigationBar)
      .toolbarBackground(.visible, for: .navigationBar)
  }
}
