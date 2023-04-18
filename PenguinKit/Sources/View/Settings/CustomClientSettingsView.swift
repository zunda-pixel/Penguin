//
//  CustomClientSettingsView.swift
//

import Sweet
import SwiftUI

struct CustomClientSettingsView: View {
  @StateObject var viewModel = CustomClientSettingsViewModel()
  @Binding var currentUser: Sweet.UserModel?
  @Binding var loginUsers: [Sweet.UserModel]

  var body: some View {
    List {
      Section {
        Text("If you set Client, all accounts will be reset.")
      }

      Section {
        TextField("Client ID", text: $viewModel.clientID)
        SecureField("Client Secret Key", text: $viewModel.clientSecretKey)
        
        NavigationLink("Set up API Settings") {
          SetUpAPIView()
        }
      }

      Section {
        Button("Set") {
          viewModel.submit()
        }

        Button("Reset") {
          viewModel.reset()
        }
      }
    }
    .onDisappear {
      currentUser = Secure.currentUser
      loginUsers = Secure.loginUsers
    }
  }
}

struct CustomClientSettingsView_Previews: PreviewProvider {
  static var previews: some View {
    NavigationStack {
      CustomClientSettingsView(currentUser: .constant(nil), loginUsers: .constant([]))
    }
  }
}
