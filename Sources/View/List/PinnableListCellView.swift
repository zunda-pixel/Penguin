//
// PinnableListCellView.swift
//

import OrderedCollections
import Sweet
import SwiftUI

protocol PinnableListCellDelegate {
  func togglePin(listID: String) async
}

struct PinnableListCellView: View {
  let list: Sweet.ListModel
  let owner: Sweet.UserModel
  let userID: String
  let delegate: PinnableListCellDelegate
  let isPinned: Bool

  var body: some View {
    HStack {
      ListCellView(list: list, owner: owner, userID: userID)
      Image(systemName: "pin")
        .if(isPinned) {
          $0.symbolVariant(.fill)
        }
        .onTapGesture {
          Task {
            await delegate.togglePin(listID: list.id)
          }
        }
    }
  }
}
