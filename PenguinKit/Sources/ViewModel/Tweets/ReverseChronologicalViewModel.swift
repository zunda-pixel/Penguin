//
//  ReverseChronologicalViewModel.swift
//

import Algorithms
import CoreData
import Foundation
import Sweet

final class ReverseChronologicalViewModel: ReverseChronologicalTweetsViewProtocol {
  let userID: String

  let backgroundContext: NSManagedObjectContext

  @Published var errorHandle: ErrorHandle?
  @Published var reply: Reply?
  @Published var timelines: [Timeline]

  init(userID: String) {
    self.userID = userID
    self.backgroundContext = PersistenceController.shared.container.newBackgroundContext()
    self.backgroundContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump

    self.timelines = []
  }
}
