//
//  NewListDelegate.swift
//

import SwiftUI

struct NewListView: View {
  @Environment(\.dismiss) var dismiss

  @StateObject var viewModel: NewListViewModel

  @FocusState var focus: Bool?

  var body: some View {
    NavigationStack {
      List {
        Group {
          TextField("Name", text: $viewModel.name)
            .focused($focus, equals: true)
          TextField("Description", text: $viewModel.description)
          Toggle("Private", isOn: $viewModel.isPrivate)
        }
        .listContentAttribute()
      }
      .navigationBarAttribute()
      .scrollViewAttitude()
      .onAppear {
        focus = true
      }
      .alert(errorHandle: $viewModel.errorHandle)
      .navigationTitle("New List")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .navigationBarTrailing) {
          Button("Save") {
            Task {
              do {
                try await viewModel.createList()
                dismiss()
              } catch {
                viewModel.errorHandle = ErrorHandle(error: error)
              }
            }
          }
          .disabled(viewModel.disableCreateList)

        }

        ToolbarItem(placement: .navigationBarLeading) {
          Button("Cancel") {
            dismiss()
          }
        }
      }
    }
  }
}
