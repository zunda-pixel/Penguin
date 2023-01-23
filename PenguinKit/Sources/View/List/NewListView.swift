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
      .navigationBarTitleDisplayModeIfAvailable(.inline)
      .toolbar {
#if os(macOS)
let savePlacement: ToolbarItemPlacement = .navigation
#else
let savePlacement: ToolbarItemPlacement = .navigationBarTrailing
#endif
        
        ToolbarItem(placement: savePlacement) {
          Button("Save") {
            Task {
              do {
                try await viewModel.createList()
                dismiss()
              } catch {
                let errorHandle = ErrorHandle(error: error)
                errorHandle.log()
                viewModel.errorHandle = errorHandle
              }
            }
          }
          .disabled(viewModel.disableCreateList)
        }
        
#if os(macOS)
let cancelPlacement: ToolbarItemPlacement = .navigation
#else
let cancelPlacement: ToolbarItemPlacement = .navigationBarLeading
#endif

        ToolbarItem(placement: cancelPlacement) {
          Button("Cancel") {
            dismiss()
          }
        }
      }
    }
  }
}
