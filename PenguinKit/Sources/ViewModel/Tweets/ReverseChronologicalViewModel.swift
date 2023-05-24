//
//  ReverseChronologicalViewModel.swift
//

import Algorithms
import CoreData
import Foundation
import Sweet

final class ReverseChronologicalViewModel: ReverseChronologicalTweetsViewProtocol {
  let userID: String

  let viewContext: NSManagedObjectContext
  let backgroundContext: NSManagedObjectContext

  @Published var errorHandle: ErrorHandle?
  @Published var reply: Reply?
  @Published var timelines: [Timeline]

  init(userID: String) {
    self.userID = userID
    
    let container = PersistenceController.shared.container
    self.viewContext = container.viewContext
    self.backgroundContext = container.newBackgroundContext()
    self.backgroundContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump

    self.timelines = []
  }
}
