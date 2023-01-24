//
//  DirectMessageDetailView.swift
//

import Algorithms
import Sweet
import SwiftUI

struct DirectMessageDetailView: View {
  @ObservedObject var viewModel: DirectMessageDetailViewModel

  var body: some View {
    ScrollView {
      LazyVStack {
        ForEach(viewModel.showDirectMessages.indexed(), id: \.index) { index, dm in
          let beforeDM = viewModel.showDirectMessages[safe: index - 1]
          let isBeforeElementSame = dm.senderID == beforeDM?.senderID

          let cellViewModel = viewModel.cellViewModel(
            directMessage: dm, isBeforeElementSame: isBeforeElementSame)
          let isOwned = viewModel.userID == dm.senderID

          HStack {
            if isOwned { Spacer() }

            DirectMessageCell(viewModel: cellViewModel)

            if !isOwned { Spacer() }
          }
          .task {
            if viewModel.showDirectMessages.last?.id == dm.id {
              await viewModel.fetchDirectMessages()
            }
          }
        }
      }
      .padding(.horizontal)
    }
    .scrollViewAttitude()
    .safeAreaInset(edge: .bottom) {
      HStack(alignment: .bottom) {
        Label("Camera", systemImage: "camera")

        Label("Photo", systemImage: "photo")

        TextField("", text: $viewModel.text, axis: .vertical)
        .textFieldStyle(.roundedBorder)

        Button {
          Task {
            await viewModel.send()
          }
        } label: {
          Label("Send", systemImage: "arrow.up.circle.fill")
        }
      }
      .labelStyle(.iconOnly)
      .padding()
      .background(.ultraThinMaterial)
    }
    #if !os(macOS)
      .toolbar(.hidden, for: .tabBar)
    #endif
    .scrollDismissesKeyboard(.immediately)
    .task {
      await viewModel.fetchDirectMessages()
    }
  }
}
