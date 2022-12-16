//
//  Persistence.swift
//

import CoreData

struct PersistenceController {
  static let shared = PersistenceController()

  let container: NSPersistentCloudKitContainer

  init(inMemory: Bool = false) {
    container = NSPersistentCloudKitContainer(name: "Penguin")
    if inMemory {
      container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
    }
    container.loadPersistentStores(completionHandler: { (storeDescription, error) in
      if let error = error as NSError? {
        fatalError("\(error)")
      }
    })
    container.viewContext.automaticallyMergesChangesFromParent = true
  }
}
