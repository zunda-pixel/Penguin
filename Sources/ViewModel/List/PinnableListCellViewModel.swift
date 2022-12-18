//
//  PinnableListCellViewModel.swift
//  Penguin
//
//  Created by zunda on 2022/12/19.
//

import Foundation
import OrderedCollections
import Sweet

protocol PinnableListCellDelegate {
  func togglePin(listID: String) async
}

class PinnableListCellViewModel: ObservableObject {
  let list: Sweet.ListModel
  let owner: Sweet.UserModel
  let userID: String
  let delegate: PinnableListCellDelegate
  let isPinned: Bool
  
  init(list: Sweet.ListModel, owner: Sweet.UserModel, userID: String, delegate: PinnableListCellDelegate, isPinned: Bool) {
    self.list = list
    self.owner = owner
    self.userID = userID
    self.delegate = delegate
    self.isPinned = isPinned
  }
}
