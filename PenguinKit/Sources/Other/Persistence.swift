//
//  Persistence.swift
//

import CoreData

struct PersistenceController {
  static let shared = PersistenceController()

  let container: NSPersistentContainer

  init(inMemory: Bool = false) {
    let modelURL = Bundle.module.url(forResource: "Penguin", withExtension: "momd")!
    let model = NSManagedObjectModel(contentsOf: modelURL)!
    container = NSPersistentContainer(name: "Penguin", managedObjectModel: model)

    if inMemory {
      container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
    }

    container.loadPersistentStores(completionHandler: { (storeDescription, error) in
      if let error = error as NSError? {
        fatalError("\(error)")
      }
    })
  }
}
