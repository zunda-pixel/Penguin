//
//  NavigationPathRouter.swift
//

import SwiftUI

final actor NavigationPathRouter: ObservableObject {
  @MainActor @Published var path = NavigationPath()
}
