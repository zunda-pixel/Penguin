//
//  NewListDelegate.swift
//

import Sweet
import SwiftUI
import os

protocol NewListDelegate {
  func didCreateList(list: Sweet.ListModel)
}

struct NewListView: View {
  @Environment(\.dismiss) var dismiss
  @State var name = ""
  @State var description = ""
  @State var isPrivate = false
  @Environment(\.settings) var settings

  let userID: String
  let delegate: NewListDelegate

  @State var errorHandle: ErrorHandle?

  @FocusState var focus: Bool?

  var disableCreateList: Bool {
    name.isEmpty
  }

  func createList() async {
    do {
      let newList = try await Sweet(userID: userID).createList(
        name: name,
        description: description,
        isPrivate: isPrivate
      )
      let response = try await Sweet(userID: userID).list(listID: newList.id)
      delegate.didCreateList(list: response.list)

      dismiss()
    } catch {
      errorHandle = ErrorHandle(error: error)
    }
  }

  var body: some View {
    NavigationStack {
      List {
        Group {
          TextField("Name", text: $name)
            .focused($focus, equals: true)
          TextField("Description", text: $description)
          Toggle("Private", isOn: $isPrivate)
        }
        .listContentAttribute()
      }
      .navigationBarAttribute()
      .scrollViewAttitude()
      .onAppear {
        focus = true
      }
      .alert(errorHandle: $errorHandle)
      .navigationTitle("New List")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .navigationBarTrailing) {
          Button("Save") {
            Task {
              await createList()
            }
          }
          .disabled(disableCreateList)

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
