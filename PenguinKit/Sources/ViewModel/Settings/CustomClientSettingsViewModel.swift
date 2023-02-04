//
//  CustomClientSettingsViewModel.swift
//

import Foundation

final class CustomClientSettingsViewModel: ObservableObject {
  @Published var clientID: String
  @Published var clientSecretKey: String
  
  var disabledSubmit: Bool {
    clientID.isEmpty || clientSecretKey.isEmpty
  }
  
  init() {
    clientID = Secure.customClient?.id ?? ""
    clientSecretKey = Secure.customClient?.secretKey ?? ""
  }
  
  func submit() {
    guard !disabledSubmit else { return }
    Secure.customClient = Client(id: clientID, secretKey: clientSecretKey)
    
    logoutAllAccount()
  }
  
  func reset() {
    Secure.customClient = nil
    clientID = ""
    clientSecretKey = ""
    
    logoutAllAccount()
  }
  
  func logoutAllAccount() {
    for user in Secure.loginUsers {
      Secure.removeUserData(userID: user.id)
    }
  }
}
