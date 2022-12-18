//
// PinnableListCellView.swift
//

import OrderedCollections
import Sweet
import SwiftUI

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


struct PinnableListCellView: View {
//  let list: Sweet.ListModel
//  let owner: Sweet.UserModel
//  let userID: String
//  let delegate: PinnableListCellDelegate
//  let isPinned: Bool
  @StateObject var viewModel: PinnableListCellViewModel

  var body: some View {
    HStack {
      ListCellView(list: viewModel.list, owner: viewModel.owner, userID: viewModel.userID)
      Image(systemName: "pin")
        .if(viewModel.isPinned) {
          $0.symbolVariant(.fill)
        }
        .onTapGesture {
          Task {
            await viewModel.delegate.togglePin(listID: viewModel.list.id)
          }
        }
    }
  }
}
