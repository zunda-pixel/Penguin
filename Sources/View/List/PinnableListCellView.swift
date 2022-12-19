//
// PinnableListCellView.swift
//

import SwiftUI

struct PinnableListCellView: View {
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
