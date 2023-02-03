//
//  CustomClientSettingsView.swift
//

import SwiftUI
import Sweet

struct CustomClientSettingsView: View {
  @StateObject var viewModel = CustomClientSettingsViewModel()
  @Binding var currentUser: Sweet.UserModel?
  @Binding var loginUsers: [Sweet.UserModel]
  
  var body: some View {
    Form {
      Section {
        Text("If you set/reset client, All account are logout")
      }
      
      Section {
        TextField("Client ID", text: $viewModel.clientID)
        SecureField("Client Secret Key", text: $viewModel.clientSecretKey)
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
