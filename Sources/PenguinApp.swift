//
//  PenguinApp.swift
//

import Sweet
import SwiftUI

@main
struct PenguinApp: App {
  let persistenceController = PersistenceController.shared

  var body: some Scene {
    WindowGroup {
      ContentView()
        .environment(\.managedObjectContext, persistenceController.container.viewContext)
    }
  }
}
